`include "defines.svh"

module ctrl (

    input logic rst,

    input logic stallreq_from_id,

    //来自执行阶段的暂停请求
    input  logic       stallreq_from_ex,
    output logic [5:0] stall

);

    always_comb begin
        if (rst == `RstEnable) begin
            stall = 6'b000000;
        end else if (stallreq_from_ex == `Stop) begin
            stall = 6'b001111;
        end else if (stallreq_from_id == `Stop) begin
            stall = 6'b000111;
        end else begin
            stall = 6'b000000;
        end  //if
    end  //always


endmodule
