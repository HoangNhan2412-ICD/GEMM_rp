`timescale 1ns/1ps
// Processing Element: signed INT8 multiply-accumulate with explicit reset/clear.
module PE #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         clear,
    input  wire                         valid_i,
    input  wire signed [DATA_WIDTH-1:0] feature_i,
    input  wire signed [DATA_WIDTH-1:0] weight_i,
    output reg  signed [ACC_WIDTH-1:0]  acc_o,
    output reg                          valid_o
);
    wire signed [(2*DATA_WIDTH)-1:0] product;
    assign product = feature_i * weight_i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_o   <= {ACC_WIDTH{1'b0}};
            valid_o <= 1'b0;
        end else if (clear) begin
            acc_o   <= {ACC_WIDTH{1'b0}};
            valid_o <= 1'b0;
        end else begin
            valid_o <= valid_i;
            if (valid_i) begin
                acc_o <= acc_o + {{(ACC_WIDTH-(2*DATA_WIDTH)){product[(2*DATA_WIDTH)-1]}}, product};
            end
        end
    end
endmodule
