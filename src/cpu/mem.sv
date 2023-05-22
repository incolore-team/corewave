`include "defines.svh"

module mem (

    input logic rst,

    //来自执行阶段的信息	
    input logic [`RegAddrBus] wd_i,
    input logic               wreg_i,
    input logic [    `RegBus] wdata_i,
    input logic [    `RegBus] hi_i,
    input logic [    `RegBus] lo_i,
    input logic               whilo_i,

    //送到回写阶段的信息
    output logic [`RegAddrBus] wd_o,
    output logic               wreg_o,
    output logic [    `RegBus] wdata_o,
    output logic [    `RegBus] hi_o,
    output logic [    `RegBus] lo_o,
    output logic               whilo_o

);


    always_comb begin
        if (rst == `RstEnable) begin
            wd_o    = `NOPRegAddr;
            wreg_o  = `WriteDisable;
            wdata_o = `ZeroWord;
            hi_o    = `ZeroWord;
            lo_o    = `ZeroWord;
            whilo_o = `WriteDisable;
        end else begin
            wd_o    = wd_i;
            wreg_o  = wreg_i;
            wdata_o = wdata_i;
            hi_o    = hi_i;
            lo_o    = lo_i;
            whilo_o = whilo_i;
        end  //if
    end  //always


endmodule
