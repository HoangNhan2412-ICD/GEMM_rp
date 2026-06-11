`timescale 1ns/1ps
// Compute pipeline top: stream input collector -> one-entry buffer -> MM -> output serializer.
module MM_ultra #(
    parameter ROWS = 4,
    parameter COLS = 4,
    parameter K = 4,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 32,
    parameter OUT_WIDTH = 8,
    parameter SHIFT_WIDTH = 5
)(
    input  wire clk,
    input  wire rst_n,
    input  wire signed [DATA_WIDTH-1:0] feature_tdata,
    input  wire feature_tvalid,
    output wire feature_tready,
    input  wire feature_tlast,
    input  wire signed [DATA_WIDTH-1:0] weight_tdata,
    input  wire weight_tvalid,
    output wire weight_tready,
    input  wire weight_tlast,
    input  wire [SHIFT_WIDTH-1:0] shift_i,
    output wire signed [OUT_WIDTH-1:0] out_tdata,
    output wire out_tvalid,
    input  wire out_tready,
    output wire out_tlast,
    output wire protocol_error_o
);
    wire in_valid;
    wire in_ready;
    wire buf_valid;
    wire buf_ready;
    wire mm_valid;
    wire out_ready;
    wire signed [(ROWS*K*DATA_WIDTH)-1:0] in_features;
    wire signed [(K*COLS*DATA_WIDTH)-1:0] in_weights;
    wire signed [(ROWS*K*DATA_WIDTH)-1:0] buf_features;
    wire signed [(K*COLS*DATA_WIDTH)-1:0] buf_weights;
    wire signed [(ROWS*COLS*ACC_WIDTH)-1:0] mm_results;

    MM_in_buffer #(.ROWS(ROWS), .COLS(COLS), .K(K), .DATA_WIDTH(DATA_WIDTH)) u_in (
        .clk(clk), .rst_n(rst_n),
        .feature_tdata(feature_tdata), .feature_tvalid(feature_tvalid), .feature_tready(feature_tready), .feature_tlast(feature_tlast),
        .weight_tdata(weight_tdata), .weight_tvalid(weight_tvalid), .weight_tready(weight_tready), .weight_tlast(weight_tlast),
        .features_o(in_features), .weights_o(in_weights), .block_valid_o(in_valid), .block_ready_i(in_ready),
        .protocol_error_o(protocol_error_o)
    );

    MM_buffer #(.ROWS(ROWS), .COLS(COLS), .K(K), .DATA_WIDTH(DATA_WIDTH)) u_buffer (
        .clk(clk), .rst_n(rst_n), .valid_i(in_valid), .ready_o(in_ready),
        .features_i(in_features), .weights_i(in_weights), .valid_o(buf_valid), .ready_i(buf_ready),
        .features_o(buf_features), .weights_o(buf_weights)
    );

    assign buf_ready = out_ready;

    MM #(.ROWS(ROWS), .COLS(COLS), .K(K), .DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)) u_mm (
        .clk(clk), .rst_n(rst_n), .valid_i(buf_valid && buf_ready),
        .features_i(buf_features), .weights_i(buf_weights), .valid_o(mm_valid), .results_o(mm_results)
    );

    MM_out_buffer #(.ROWS(ROWS), .COLS(COLS), .ACC_WIDTH(ACC_WIDTH), .OUT_WIDTH(OUT_WIDTH), .SHIFT_WIDTH(SHIFT_WIDTH)) u_out (
        .clk(clk), .rst_n(rst_n), .valid_i(mm_valid), .ready_o(out_ready), .results_i(mm_results),
        .shift_i(shift_i), .out_tdata(out_tdata), .out_tvalid(out_tvalid), .out_tready(out_tready), .out_tlast(out_tlast)
    );
endmodule
