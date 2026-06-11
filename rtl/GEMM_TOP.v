`timescale 1ns/1ps
// Minimal AXI-Stream oriented wrapper placeholder. AXI4-Lite control/IP integration is TODO.
module GEMM_TOP #(
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
    input  wire signed [DATA_WIDTH-1:0] s_axis_feature_tdata,
    input  wire s_axis_feature_tvalid,
    output wire s_axis_feature_tready,
    input  wire s_axis_feature_tlast,
    input  wire signed [DATA_WIDTH-1:0] s_axis_weight_tdata,
    input  wire s_axis_weight_tvalid,
    output wire s_axis_weight_tready,
    input  wire s_axis_weight_tlast,
    input  wire [SHIFT_WIDTH-1:0] cfg_shift,
    output wire signed [OUT_WIDTH-1:0] m_axis_out_tdata,
    output wire m_axis_out_tvalid,
    input  wire m_axis_out_tready,
    output wire m_axis_out_tlast,
    output wire protocol_error_o
);
    MM_ultra #(
        .ROWS(ROWS), .COLS(COLS), .K(K), .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH), .OUT_WIDTH(OUT_WIDTH), .SHIFT_WIDTH(SHIFT_WIDTH)
    ) u_mm_ultra (
        .clk(clk), .rst_n(rst_n),
        .feature_tdata(s_axis_feature_tdata), .feature_tvalid(s_axis_feature_tvalid), .feature_tready(s_axis_feature_tready), .feature_tlast(s_axis_feature_tlast),
        .weight_tdata(s_axis_weight_tdata), .weight_tvalid(s_axis_weight_tvalid), .weight_tready(s_axis_weight_tready), .weight_tlast(s_axis_weight_tlast),
        .shift_i(cfg_shift), .out_tdata(m_axis_out_tdata), .out_tvalid(m_axis_out_tvalid), .out_tready(m_axis_out_tready), .out_tlast(m_axis_out_tlast),
        .protocol_error_o(protocol_error_o)
    );
endmodule
