`timescale 1ns/1ps
module PE_line #(
    parameter COLS = 4,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 32
)(
    input  wire clk,
    input  wire rst_n,
    input  wire clear,
    input  wire valid_i,
    input  wire signed [DATA_WIDTH-1:0] feature_i,
    input  wire signed [(COLS*DATA_WIDTH)-1:0] weights_i,
    output wire signed [(COLS*ACC_WIDTH)-1:0] accs_o,
    output wire [(COLS)-1:0] valids_o
);
    genvar c;
    generate
        for (c = 0; c < COLS; c = c + 1) begin : gen_pe
            PE #(.DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)) u_pe (
                .clk(clk), .rst_n(rst_n), .clear(clear), .valid_i(valid_i),
                .feature_i(feature_i),
                .weight_i(weights_i[(c*DATA_WIDTH) +: DATA_WIDTH]),
                .acc_o(accs_o[(c*ACC_WIDTH) +: ACC_WIDTH]),
                .valid_o(valids_o[c])
            );
        end
    endgenerate
endmodule
