`timescale 1ns/1ps
// Matrix multiply wrapper. One-cycle registered valid after valid_i.
module MM #(
    parameter ROWS = 4,
    parameter COLS = 4,
    parameter K = 4,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 32
)(
    input  wire clk,
    input  wire rst_n,
    input  wire valid_i,
    input  wire signed [(ROWS*K*DATA_WIDTH)-1:0] features_i,
    input  wire signed [(K*COLS*DATA_WIDTH)-1:0] weights_i,
    output reg  valid_o,
    output reg  signed [(ROWS*COLS*ACC_WIDTH)-1:0] results_o
);
    wire signed [(ROWS*COLS*ACC_WIDTH)-1:0] comb_results;

    PE_array #(
        .ROWS(ROWS), .COLS(COLS), .K(K), .DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)
    ) u_pe_array (
        .features_i(features_i), .weights_i(weights_i), .results_o(comb_results)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_o <= 1'b0;
            results_o <= {(ROWS*COLS*ACC_WIDTH){1'b0}};
        end else begin
            valid_o <= valid_i;
            if (valid_i) begin
                results_o <= comb_results;
            end
        end
    end
endmodule
