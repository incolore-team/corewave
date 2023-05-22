`include "defines.svh"
`timescale 1ns / 1ps

module openmips_min_sopc_tb ();

    logic                CLOCK_50;
    logic                rst;

    logic                rom_ce;
    logic [`InstAddrBus] inst_addr;
    logic [    `InstBus] inst;

    initial begin
        $dumpfile("build/wave.vcd");
        $dumpvars(0, openmips_min_sopc_tb);
    end

    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        rst = `RstEnable;
        #195 rst = `RstDisable;
        #10000 $stop;
    end

    openmips_min_sopc openmips_min_sopc0 (
        .clk(CLOCK_50),
        .rst(rst),

        .rom_ce(rom_ce),
        .inst_addr(inst_addr),
        .inst(inst)
    );

    inst_rom inst_rom0 (
        .ce  (rom_ce),
        .addr(inst_addr),
        .inst(inst)
    );

endmodule
