`include "defines.svh"

module openmips_min_sopc (

    input logic clk,
    input logic rst,

    //连接指令存储器
    output logic                rom_ce,
    output logic [`InstAddrBus] inst_addr,
    input  logic [    `InstBus] inst

);

    openmips openmips0 (
        .clk(clk),
        .rst(rst),

        .rom_addr_o(inst_addr),
        .rom_data_i(inst),
        .rom_ce_o  (rom_ce)

    );

endmodule
