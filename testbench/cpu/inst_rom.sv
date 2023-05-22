`include "defines.svh"

module inst_rom (

    // input wire clk,
    input  logic                ce,
    input  logic [`InstAddrBus] addr,
    output logic [    `InstBus] inst

);

    logic [`InstBus] inst_mem[0:`InstMemNum-1];

    always_comb begin
        if (ce == `ChipDisable) begin
            inst = `ZeroWord;
        end else begin
            inst = inst_mem[addr[`InstMemNumLog2+1:2]];
        end
    end

endmodule
