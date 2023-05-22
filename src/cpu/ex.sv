`include "defines.svh"

module ex (

    input logic rst,

    //送到执行阶段的信息
    input logic [  `AluOpBus] aluop_i,
    input logic [ `AluSelBus] alusel_i,
    input logic [    `RegBus] reg1_i,
    input logic [    `RegBus] reg2_i,
    input logic [`RegAddrBus] wd_i,
    input logic               wreg_i,

    //HI、LO寄存器的值
    input logic [`RegBus] hi_i,
    input logic [`RegBus] lo_i,

    //回写阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
    input logic [`RegBus] wb_hi_i,
    input logic [`RegBus] wb_lo_i,
    input logic           wb_whilo_i,

    //访存阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
    input logic [`RegBus] mem_hi_i,
    input logic [`RegBus] mem_lo_i,
    input logic           mem_whilo_i,

    input logic [`DoubleRegBus] hilo_temp_i,
    input logic [          1:0] cnt_i,

    //与除法模块相连
    input logic [`DoubleRegBus] div_result_i,
    input logic                 div_ready_i,

    //是否转移、以及link address
    input logic [`RegBus] link_address_i,
    input logic           is_in_delayslot_i,

    output logic [`RegAddrBus] wd_o,
    output logic               wreg_o,
    output logic [    `RegBus] wdata_o,

    output logic [`RegBus] hi_o,
    output logic [`RegBus] lo_o,
    output logic           whilo_o,

    output logic [`DoubleRegBus] hilo_temp_o,
    output logic [          1:0] cnt_o,

    output logic [`RegBus] div_opdata1_o,
    output logic [`RegBus] div_opdata2_o,
    output logic           div_start_o,
    output logic           signed_div_o,

    output logic stallreq

);

    logic [`RegBus] logicout;
    logic [`RegBus] shiftres;
    logic [`RegBus] moveres;
    logic [`RegBus] arithmeticres;
    logic [`DoubleRegBus] mulres;
    logic [`RegBus] HI;
    logic [`RegBus] LO;
    logic [`RegBus] reg2_i_mux;
    logic [`RegBus] reg1_i_not;
    logic [`RegBus] result_sum;
    logic ov_sum;
    logic reg1_eq_reg2;
    logic reg1_lt_reg2;
    logic [`RegBus] opdata1_mult;
    logic [`RegBus] opdata2_mult;
    logic [`DoubleRegBus] hilo_temp;
    logic [`DoubleRegBus] hilo_temp1;
    logic stallreq_for_madd_msub;
    logic stallreq_for_div;

    always_comb begin
        if (rst == `RstEnable) begin
            logicout = `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_OR_OP: begin
                    logicout = reg1_i | reg2_i;
                end
                `EXE_AND_OP: begin
                    logicout = reg1_i & reg2_i;
                end
                `EXE_NOR_OP: begin
                    logicout = ~(reg1_i | reg2_i);
                end
                `EXE_XOR_OP: begin
                    logicout = reg1_i ^ reg2_i;
                end
                default: begin
                    logicout = `ZeroWord;
                end
            endcase
        end  //if
    end  //always

    always_comb begin
        if (rst == `RstEnable) begin
            shiftres = `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLL_OP: begin
                    shiftres = reg2_i << reg1_i[4:0];
                end
                `EXE_SRL_OP: begin
                    shiftres = reg2_i >> reg1_i[4:0];
                end
                `EXE_SRA_OP: begin
                    shiftres = ({32{reg2_i[31]}} << (6'd32 - {1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
                end
                default: begin
                    shiftres = `ZeroWord;
                end
            endcase
        end  //if
    end  //always

    assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) || (aluop_i == `EXE_SLT_OP) ) ? (~reg2_i)+1 : reg2_i;

    assign result_sum = reg1_i + reg2_i_mux;

    assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) || ((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));

    assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP)) ?  ((reg1_i[31] && !reg2_i[31]) || (!reg1_i[31] && !reg2_i[31] && result_sum[31])|| (reg1_i[31] && reg2_i[31] && result_sum[31])) : (reg1_i < reg2_i);

    assign reg1_i_not = ~reg1_i;

    always_comb begin
        if (rst == `RstEnable) begin
            arithmeticres = `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLT_OP, `EXE_SLTU_OP: begin
                    arithmeticres = reg1_lt_reg2;
                end
                `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP: begin
                    arithmeticres = result_sum;
                end
                `EXE_SUB_OP, `EXE_SUBU_OP: begin
                    arithmeticres = result_sum;
                end
                `EXE_CLZ_OP: begin
                    arithmeticres = reg1_i[31] ? 0 : reg1_i[30] ? 1 : reg1_i[29] ? 2 : reg1_i[28] ? 3 : reg1_i[27] ? 4 : reg1_i[26] ? 5 : reg1_i[25] ? 6 : reg1_i[24] ? 7 : reg1_i[23] ? 8 : reg1_i[22] ? 9 : reg1_i[21] ? 10 : reg1_i[20] ? 11 : reg1_i[19] ? 12 : reg1_i[18] ? 13 : reg1_i[17] ? 14 : reg1_i[16] ? 15 : reg1_i[15] ? 16 : reg1_i[14] ? 17 : reg1_i[13] ? 18 : reg1_i[12] ? 19 : reg1_i[11] ? 20 : reg1_i[10] ? 21 : reg1_i[9] ? 22 : reg1_i[8] ? 23 : reg1_i[7] ? 24 : reg1_i[6] ? 25 : reg1_i[5] ? 26 : reg1_i[4] ? 27 : reg1_i[3] ? 28 : reg1_i[2] ? 29 : reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32 ;
                end
                `EXE_CLO_OP: begin
                    arithmeticres = (reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 : reg1_i_not[29] ? 2 : reg1_i_not[28] ? 3 : reg1_i_not[27] ? 4 : reg1_i_not[26] ? 5 : reg1_i_not[25] ? 6 : reg1_i_not[24] ? 7 : reg1_i_not[23] ? 8 : reg1_i_not[22] ? 9 : reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 : reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 : reg1_i_not[17] ? 14 : reg1_i_not[16] ? 15 : reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 : reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 : reg1_i_not[11] ? 20 : reg1_i_not[10] ? 21 : reg1_i_not[9] ? 22 : reg1_i_not[8] ? 23 : reg1_i_not[7] ? 24 : reg1_i_not[6] ? 25 : reg1_i_not[5] ? 26 : reg1_i_not[4] ? 27 : reg1_i_not[3] ? 28 : reg1_i_not[2] ? 29 : reg1_i_not[1] ? 30 : reg1_i_not[0] ? 31 : 32) ;
                end
                default: begin
                    arithmeticres = `ZeroWord;
                end
            endcase
        end
    end

    //取得乘法操作的操作数，如果是有符号除法且操作数是负数，那么取反加一
    assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;

    assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) && (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;

    assign hilo_temp = opdata1_mult * opdata2_mult;

    always_comb begin
        if (rst == `RstEnable) begin
            mulres = {`ZeroWord, `ZeroWord};
        end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP))begin
            if (reg1_i[31] ^ reg2_i[31] == 1'b1) begin
                mulres = ~hilo_temp + 1;
            end else begin
                mulres = hilo_temp;
            end
        end else begin
            mulres = hilo_temp;
        end
    end

    //得到最新的HI、LO寄存器的值，此处要解决指令数据相关问题
    always_comb begin
        if (rst == `RstEnable) begin
            {HI, LO} = {`ZeroWord, `ZeroWord};
        end else if (mem_whilo_i == `WriteEnable) begin
            {HI, LO} = {mem_hi_i, mem_lo_i};
        end else if (wb_whilo_i == `WriteEnable) begin
            {HI, LO} = {wb_hi_i, wb_lo_i};
        end else begin
            {HI, LO} = {hi_i, lo_i};
        end
    end

    always_comb begin
        stallreq = stallreq_for_madd_msub || stallreq_for_div;
    end

    //MADD、MADDU、MSUB、MSUBU指令
    always_comb begin
        if (rst == `RstEnable) begin
            hilo_temp_o            = {`ZeroWord, `ZeroWord};
            cnt_o                  = 2'b00;
            stallreq_for_madd_msub = `NoStop;
        end else begin

            case (aluop_i)
                `EXE_MADD_OP, `EXE_MADDU_OP: begin
                    if (cnt_i == 2'b00) begin
                        hilo_temp_o            = mulres;
                        cnt_o                  = 2'b01;
                        stallreq_for_madd_msub = `Stop;
                        hilo_temp1             = {`ZeroWord, `ZeroWord};
                    end else if (cnt_i == 2'b01) begin
                        hilo_temp_o            = {`ZeroWord, `ZeroWord};
                        cnt_o                  = 2'b10;
                        hilo_temp1             = hilo_temp_i + {HI, LO};
                        stallreq_for_madd_msub = `NoStop;
                    end
                end
                `EXE_MSUB_OP, `EXE_MSUBU_OP: begin
                    if (cnt_i == 2'b00) begin
                        hilo_temp_o            = ~mulres + 1;
                        cnt_o                  = 2'b01;
                        stallreq_for_madd_msub = `Stop;
                    end else if (cnt_i == 2'b01) begin
                        hilo_temp_o            = {`ZeroWord, `ZeroWord};
                        cnt_o                  = 2'b10;
                        hilo_temp1             = hilo_temp_i + {HI, LO};
                        stallreq_for_madd_msub = `NoStop;
                    end
                end
                default: begin
                    hilo_temp_o            = {`ZeroWord, `ZeroWord};
                    cnt_o                  = 2'b00;
                    stallreq_for_madd_msub = `NoStop;
                end
            endcase
        end
    end

    //DIV、DIVU指令
    always_comb begin
        if (rst == `RstEnable) begin
            stallreq_for_div = `NoStop;
            div_opdata1_o    = `ZeroWord;
            div_opdata2_o    = `ZeroWord;
            div_start_o      = `DivStop;
            signed_div_o     = 1'b0;
        end else begin
            stallreq_for_div = `NoStop;
            div_opdata1_o    = `ZeroWord;
            div_opdata2_o    = `ZeroWord;
            div_start_o      = `DivStop;
            signed_div_o     = 1'b0;
            case (aluop_i)
                `EXE_DIV_OP: begin
                    if (div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o    = reg1_i;
                        div_opdata2_o    = reg2_i;
                        div_start_o      = `DivStart;
                        signed_div_o     = 1'b1;
                        stallreq_for_div = `Stop;
                    end else if (div_ready_i == `DivResultReady) begin
                        div_opdata1_o    = reg1_i;
                        div_opdata2_o    = reg2_i;
                        div_start_o      = `DivStop;
                        signed_div_o     = 1'b1;
                        stallreq_for_div = `NoStop;
                    end else begin
                        div_opdata1_o    = `ZeroWord;
                        div_opdata2_o    = `ZeroWord;
                        div_start_o      = `DivStop;
                        signed_div_o     = 1'b0;
                        stallreq_for_div = `NoStop;
                    end
                end
                `EXE_DIVU_OP: begin
                    if (div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o    = reg1_i;
                        div_opdata2_o    = reg2_i;
                        div_start_o      = `DivStart;
                        signed_div_o     = 1'b0;
                        stallreq_for_div = `Stop;
                    end else if (div_ready_i == `DivResultReady) begin
                        div_opdata1_o    = reg1_i;
                        div_opdata2_o    = reg2_i;
                        div_start_o      = `DivStop;
                        signed_div_o     = 1'b0;
                        stallreq_for_div = `NoStop;
                    end else begin
                        div_opdata1_o    = `ZeroWord;
                        div_opdata2_o    = `ZeroWord;
                        div_start_o      = `DivStop;
                        signed_div_o     = 1'b0;
                        stallreq_for_div = `NoStop;
                    end
                end
                default: begin
                end
            endcase
        end
    end

    //MFHI、MFLO、MOVN、MOVZ指令
    always_comb begin
        if (rst == `RstEnable) begin
            moveres = `ZeroWord;
        end else begin
            moveres = `ZeroWord;
            case (aluop_i)
                `EXE_MFHI_OP: begin
                    moveres = HI;
                end
                `EXE_MFLO_OP: begin
                    moveres = LO;
                end
                `EXE_MOVZ_OP: begin
                    moveres = reg1_i;
                end
                `EXE_MOVN_OP: begin
                    moveres = reg1_i;
                end
                default: begin
                end
            endcase
        end
    end

    always_comb begin
        wd_o = wd_i;

        if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
            wreg_o = `WriteDisable;
        end else begin
            wreg_o = wreg_i;
        end

        case (alusel_i)
            `EXE_RES_LOGIC: begin
                wdata_o = logicout;
            end
            `EXE_RES_SHIFT: begin
                wdata_o = shiftres;
            end
            `EXE_RES_MOVE: begin
                wdata_o = moveres;
            end
            `EXE_RES_ARITHMETIC: begin
                wdata_o = arithmeticres;
            end
            `EXE_RES_MUL: begin
                wdata_o = mulres[31:0];
            end
            `EXE_RES_JUMP_BRANCH: begin
                wdata_o = link_address_i;
            end
            default: begin
                wdata_o = `ZeroWord;
            end
        endcase
    end

    always_comb begin
        if (rst == `RstEnable) begin
            whilo_o = `WriteDisable;
            hi_o    = `ZeroWord;
            lo_o    = `ZeroWord;
        end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin
            whilo_o = `WriteEnable;
            hi_o    = mulres[63:32];
            lo_o    = mulres[31:0];
        end else if ((aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MADDU_OP)) begin
            whilo_o = `WriteEnable;
            hi_o    = hilo_temp1[63:32];
            lo_o    = hilo_temp1[31:0];
        end else if ((aluop_i == `EXE_MSUB_OP) || (aluop_i == `EXE_MSUBU_OP)) begin
            whilo_o = `WriteEnable;
            hi_o    = hilo_temp1[63:32];
            lo_o    = hilo_temp1[31:0];
        end else if ((aluop_i == `EXE_DIV_OP) || (aluop_i == `EXE_DIVU_OP)) begin
            whilo_o = `WriteEnable;
            hi_o    = div_result_i[63:32];
            lo_o    = div_result_i[31:0];
        end else if (aluop_i == `EXE_MTHI_OP) begin
            whilo_o = `WriteEnable;
            hi_o    = reg1_i;
            lo_o    = LO;
        end else if (aluop_i == `EXE_MTLO_OP) begin
            whilo_o = `WriteEnable;
            hi_o    = HI;
            lo_o    = reg1_i;
        end else begin
            whilo_o = `WriteDisable;
            hi_o    = `ZeroWord;
            lo_o    = `ZeroWord;
        end
    end

endmodule
