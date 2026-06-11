`timescale 1ns/1ps
// Baseline parallel dot-product array. Packed matrices use row-major order:
// element[row][col] is bits ((row*K+col)*DATA_WIDTH)+:DATA_WIDTH.
module PE_array #(
    parameter ROWS = 4,
    parameter COLS = 4,
    parameter K = 4,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 32
)(
    input  wire signed [(ROWS*K*DATA_WIDTH)-1:0] features_i,
    input  wire signed [(K*COLS*DATA_WIDTH)-1:0] weights_i,
    output reg  signed [(ROWS*COLS*ACC_WIDTH)-1:0] results_o
);
    integer r, c, k;
    reg signed [DATA_WIDTH-1:0] a;
    reg signed [DATA_WIDTH-1:0] b;
    reg signed [ACC_WIDTH-1:0] sum;
    reg signed [(2*DATA_WIDTH)-1:0] product;

    always @* begin
        results_o = {(ROWS*COLS*ACC_WIDTH){1'b0}};
        for (r = 0; r < ROWS; r = r + 1) begin
            for (c = 0; c < COLS; c = c + 1) begin
                sum = {ACC_WIDTH{1'b0}};
                for (k = 0; k < K; k = k + 1) begin
                    a = features_i[((r*K+k)*DATA_WIDTH) +: DATA_WIDTH];
                    b = weights_i[((k*COLS+c)*DATA_WIDTH) +: DATA_WIDTH];
                    product = a * b;
                    sum = sum + {{(ACC_WIDTH-(2*DATA_WIDTH)){product[(2*DATA_WIDTH)-1]}}, product};
                end
                results_o[((r*COLS+c)*ACC_WIDTH) +: ACC_WIDTH] = sum;
            end
        end
    end
endmodule
