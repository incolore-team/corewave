`include "defines.svh"

module ex_mem (

    input logic clk,
    input logic rst,

    //来自控制模块的信息
    input logic [5:0] stall,

    //来自执行阶段的信息
    input logic [`RegAddrBus] ex_wd,
    input logic               ex_wreg,
    input logic [    `RegBus] ex_wdata,
    input logic [    `RegBus] ex_hi,
    input logic [    `RegBus] ex_lo,
    input logic               ex_whilo,

    input logic [`DoubleRegBus] hilo_i,
    input logic [          1:0] cnt_i,

    //送到访存阶段的信息
    output logic [`RegAddrBus] mem_wd,
    output logic               mem_wreg,
    output logic [    `RegBus] mem_wdata,
    output logic [    `RegBus] mem_hi,
    output logic [    `RegBus] mem_lo,
    output logic               mem_whilo,

    output logic [`DoubleRegBus] hilo_o,
    output logic [          1:0] cnt_o

);

    always_ff @(posedge clk) begin
        if (rst == `RstEnable) begin
            mem_wd    <= `NOPRegAddr;
            mem_wreg  <= `WriteDisable;
            mem_wdata <= `ZeroWord;
            mem_hi    <= `ZeroWord;
            mem_lo    <= `ZeroWord;
            mem_whilo <= `WriteDisable;
            hilo_o    <= {`ZeroWord, `ZeroWord};
            cnt_o     <= 2'b00;
        end else if (stall[3] == `Stop && stall[4] == `NoStop) begin
            mem_wd    <= `NOPRegAddr;
            mem_wreg  <= `WriteDisable;
            mem_wdata <= `ZeroWord;
            mem_hi    <= `ZeroWord;
            mem_lo    <= `ZeroWord;
            mem_whilo <= `WriteDisable;
            hilo_o    <= hilo_i;
            cnt_o     <= cnt_i;
        end else if (stall[3] == `NoStop) begin
            mem_wd    <= ex_wd;
            mem_wreg  <= ex_wreg;
            mem_wdata <= ex_wdata;
            mem_hi    <= ex_hi;
            mem_lo    <= ex_lo;
            mem_whilo <= ex_whilo;
            hilo_o    <= {`ZeroWord, `ZeroWord};
            cnt_o     <= 2'b00;
        end else begin
            hilo_o <= hilo_i;
            cnt_o  <= cnt_i;
        end  //if
    end  //always


endmodule
