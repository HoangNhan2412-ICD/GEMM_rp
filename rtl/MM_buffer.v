`timescale 1ns/1ps
// Thin registered buffer between stream input collector and compute core.
module MM_buffer #(
    parameter ROWS = 4,
    parameter COLS = 4,
    parameter K = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire clk,
    input  wire rst_n,
    input  wire valid_i,
    output wire ready_o,
    input  wire signed [(ROWS*K*DATA_WIDTH)-1:0] features_i,
    input  wire signed [(K*COLS*DATA_WIDTH)-1:0] weights_i,
    output reg  valid_o,
    input  wire ready_i,
    output reg signed [(ROWS*K*DATA_WIDTH)-1:0] features_o,
    output reg signed [(K*COLS*DATA_WIDTH)-1:0] weights_o
);
    assign ready_o = !valid_o || ready_i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_o <= 1'b0;
            features_o <= {(ROWS*K*DATA_WIDTH){1'b0}};
            weights_o <= {(K*COLS*DATA_WIDTH){1'b0}};
        end else if (ready_o) begin
            valid_o <= valid_i;
            if (valid_i) begin
                features_o <= features_i;
                weights_o <= weights_i;
            end
        end
    end
endmodule
