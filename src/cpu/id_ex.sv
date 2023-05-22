`include "defines.svh"

module id_ex (

    input logic clk,
    input logic rst,

    //来自控制模块的信息
    input logic [5:0] stall,

    //从译码阶段传递的信息
    input logic [  `AluOpBus] id_aluop,
    input logic [ `AluSelBus] id_alusel,
    input logic [    `RegBus] id_reg1,
    input logic [    `RegBus] id_reg2,
    input logic [`RegAddrBus] id_wd,
    input logic               id_wreg,
    input logic [    `RegBus] id_link_address,
    input logic               id_is_in_delayslot,
    input logic               next_inst_in_delayslot_i,

    //传递到执行阶段的信息
    output logic [  `AluOpBus] ex_aluop,
    output logic [ `AluSelBus] ex_alusel,
    output logic [    `RegBus] ex_reg1,
    output logic [    `RegBus] ex_reg2,
    output logic [`RegAddrBus] ex_wd,
    output logic               ex_wreg,
    output logic [    `RegBus] ex_link_address,
    output logic               ex_is_in_delayslot,
    output logic               is_in_delayslot_o

);

    always_ff @(posedge clk) begin
        if (rst == `RstEnable) begin
            ex_aluop           <= `EXE_NOP_OP;
            ex_alusel          <= `EXE_RES_NOP;
            ex_reg1            <= `ZeroWord;
            ex_reg2            <= `ZeroWord;
            ex_wd              <= `NOPRegAddr;
            ex_wreg            <= `WriteDisable;
            ex_link_address    <= `ZeroWord;
            ex_is_in_delayslot <= `NotInDelaySlot;
            is_in_delayslot_o  <= `NotInDelaySlot;
        end else if (stall[2] == `Stop && stall[3] == `NoStop) begin
            ex_aluop           <= `EXE_NOP_OP;
            ex_alusel          <= `EXE_RES_NOP;
            ex_reg1            <= `ZeroWord;
            ex_reg2            <= `ZeroWord;
            ex_wd              <= `NOPRegAddr;
            ex_wreg            <= `WriteDisable;
            ex_link_address    <= `ZeroWord;
            ex_is_in_delayslot <= `NotInDelaySlot;
        end else if (stall[2] == `NoStop) begin
            ex_aluop           <= id_aluop;
            ex_alusel          <= id_alusel;
            ex_reg1            <= id_reg1;
            ex_reg2            <= id_reg2;
            ex_wd              <= id_wd;
            ex_wreg            <= id_wreg;
            ex_link_address    <= id_link_address;
            ex_is_in_delayslot <= id_is_in_delayslot;
            is_in_delayslot_o  <= next_inst_in_delayslot_i;
        end
    end

endmodule
