`timescale 1ns/1ps
// Arithmetic right shift with INT8 saturation.
module right_shifter #(
    parameter IN_WIDTH = 32,
    parameter OUT_WIDTH = 8,
    parameter SHIFT_WIDTH = 5
)(
    input  wire signed [IN_WIDTH-1:0]       data_i,
    input  wire [SHIFT_WIDTH-1:0]           shift_i,
    output reg  signed [OUT_WIDTH-1:0]      data_o
);
    localparam signed [IN_WIDTH-1:0] MAX_VAL = {{(IN_WIDTH-OUT_WIDTH){1'b0}}, 1'b0, {(OUT_WIDTH-1){1'b1}}};
    localparam signed [IN_WIDTH-1:0] MIN_VAL = {{(IN_WIDTH-OUT_WIDTH){1'b1}}, 1'b1, {(OUT_WIDTH-1){1'b0}}};
    reg signed [IN_WIDTH-1:0] shifted;

    always @* begin
        shifted = data_i >>> shift_i;
        if (shifted > MAX_VAL) begin
            data_o = {1'b0, {(OUT_WIDTH-1){1'b1}}};
        end else if (shifted < MIN_VAL) begin
            data_o = {1'b1, {(OUT_WIDTH-1){1'b0}}};
        end else begin
            data_o = shifted[OUT_WIDTH-1:0];
        end
    end
endmodule
