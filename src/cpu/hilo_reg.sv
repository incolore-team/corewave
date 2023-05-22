`include "defines.svh"

module hilo_reg (

    input logic clk,
    input logic rst,

    //写端口
    input logic           we,
    input logic [`RegBus] hi_i,
    input logic [`RegBus] lo_i,

    //读端口1
    output logic [`RegBus] hi_o,
    output logic [`RegBus] lo_o

);

    always_ff @(posedge clk) begin
        if (rst == `RstEnable) begin
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
        end else if ((we == `WriteEnable)) begin
            hi_o <= hi_i;
            lo_o <= lo_i;
        end
    end

endmodule
