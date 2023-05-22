`include "defines.svh"

module pc_reg (

    input logic clk,
    input logic rst,

    //来自控制模块的信息
    input logic [5:0] stall,

    //来自译码阶段的信息
    input logic           branch_flag_i,
    input logic [`RegBus] branch_target_address_i,

    output logic [`InstAddrBus] pc,
    output logic                ce

);

    always_ff @(posedge clk) begin
        if (ce == `ChipDisable) begin
            pc <= 32'h00000000;
        end else if (stall[0] == `NoStop) begin
            if (branch_flag_i == `Branch) begin
                pc <= branch_target_address_i;
            end else begin
                pc <= pc + 4'h4;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst == `RstEnable) begin
            ce <= `ChipDisable;
        end else begin
            ce <= `ChipEnable;
        end
    end

endmodule
