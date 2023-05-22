`include "defines.svh"

module regfile (

    input logic clk,
    input logic rst,

    //写端口
    input logic               we,
    input logic [`RegAddrBus] waddr,
    input logic [    `RegBus] wdata,

    //读端口1
    input  logic               re1,
    input  logic [`RegAddrBus] raddr1,
    output logic [    `RegBus] rdata1,

    //读端口2
    input  logic               re2,
    input  logic [`RegAddrBus] raddr2,
    output logic [    `RegBus] rdata2

);

    logic [`RegBus] regs[0:`RegNum-1];

    always_ff @(posedge clk) begin
        if (rst == `RstDisable) begin
            if ((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
                regs[waddr] <= wdata;
            end
        end
    end

    always_comb begin
        if (rst == `RstEnable) begin
            rdata1 = `ZeroWord;
        end else if (raddr1 == `RegNumLog2'h0) begin
            rdata1 = `ZeroWord;
        end else if ((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin
            rdata1 = wdata;
        end else if (re1 == `ReadEnable) begin
            rdata1 = regs[raddr1];
        end else begin
            rdata1 = `ZeroWord;
        end
    end

    always_comb begin
        if (rst == `RstEnable) begin
            rdata2 = `ZeroWord;
        end else if (raddr2 == `RegNumLog2'h0) begin
            rdata2 = `ZeroWord;
        end else if ((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) begin
            rdata2 = wdata;
        end else if (re2 == `ReadEnable) begin
            rdata2 = regs[raddr2];
        end else begin
            rdata2 = `ZeroWord;
        end
    end

endmodule
