`timescale 1ns/1ps
// Signed vector adder for packed ACC_WIDTH elements in element-major order.
module AdderS #(
    parameter LANES = 4,
    parameter ACC_WIDTH = 32
)(
    input  wire signed [(LANES*ACC_WIDTH)-1:0] data_i,
    output reg  signed [ACC_WIDTH-1:0]         sum_o
);
    integer i;
    reg signed [ACC_WIDTH-1:0] lane;
    always @* begin
        sum_o = {ACC_WIDTH{1'b0}};
        for (i = 0; i < LANES; i = i + 1) begin
            lane = data_i[(i*ACC_WIDTH) +: ACC_WIDTH];
            sum_o = sum_o + lane;
        end
    end
endmodule
