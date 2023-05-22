`include "defines.svh"

module if_id (

    input logic clk,
    input logic rst,

    //来自控制模块的信息
    input logic [5:0] stall,

    input  logic [`InstAddrBus] if_pc,
    input  logic [    `InstBus] if_inst,
    output logic [`InstAddrBus] id_pc,
    output logic [    `InstBus] id_inst

);

    always_ff @(posedge clk) begin
        if (rst == `RstEnable) begin
            id_pc   <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else if (stall[1] == `Stop && stall[2] == `NoStop) begin
            id_pc   <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else if (stall[1] == `NoStop) begin
            id_pc   <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule
