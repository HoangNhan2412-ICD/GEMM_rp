`timescale 1ns/1ps
// Collects one ROWS*K feature block and one K*COLS weight block from streams.
module MM_in_buffer #(
    parameter ROWS = 4,
    parameter COLS = 4,
    parameter K = 4,
    parameter DATA_WIDTH = 8
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
    output reg  signed [(ROWS*K*DATA_WIDTH)-1:0] features_o,
    output reg  signed [(K*COLS*DATA_WIDTH)-1:0] weights_o,
    output reg  block_valid_o,
    input  wire block_ready_i,
    output reg  protocol_error_o
);
    localparam FEATURE_COUNT = ROWS*K;
    localparam WEIGHT_COUNT = K*COLS;
    localparam FEATURE_CNT_W = (FEATURE_COUNT <= 2) ? 1 : $clog2(FEATURE_COUNT+1);
    localparam WEIGHT_CNT_W = (WEIGHT_COUNT <= 2) ? 1 : $clog2(WEIGHT_COUNT+1);

    reg [FEATURE_CNT_W-1:0] feature_count;
    reg [WEIGHT_CNT_W-1:0] weight_count;
    reg feature_done;
    reg weight_done;

    assign feature_tready = rst_n && !block_valid_o && !feature_done;
    assign weight_tready  = rst_n && !block_valid_o && !weight_done;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            features_o <= {(ROWS*K*DATA_WIDTH){1'b0}};
            weights_o <= {(K*COLS*DATA_WIDTH){1'b0}};
            block_valid_o <= 1'b0;
            protocol_error_o <= 1'b0;
            feature_count <= {FEATURE_CNT_W{1'b0}};
            weight_count <= {WEIGHT_CNT_W{1'b0}};
            feature_done <= 1'b0;
            weight_done <= 1'b0;
        end else begin
            if (block_valid_o && block_ready_i) begin
                block_valid_o <= 1'b0;
                feature_count <= {FEATURE_CNT_W{1'b0}};
                weight_count <= {WEIGHT_CNT_W{1'b0}};
                feature_done <= 1'b0;
                weight_done <= 1'b0;
            end

            if (feature_tvalid && feature_tready) begin
                features_o[(feature_count*DATA_WIDTH) +: DATA_WIDTH] <= feature_tdata;
                if (feature_tlast != (feature_count == FEATURE_COUNT-1)) begin
                    protocol_error_o <= 1'b1;
                end
                if (feature_count == FEATURE_COUNT-1) begin
                    feature_done <= 1'b1;
                end else begin
                    feature_count <= feature_count + 1'b1;
                end
            end

            if (weight_tvalid && weight_tready) begin
                weights_o[(weight_count*DATA_WIDTH) +: DATA_WIDTH] <= weight_tdata;
                if (weight_tlast != (weight_count == WEIGHT_COUNT-1)) begin
                    protocol_error_o <= 1'b1;
                end
                if (weight_count == WEIGHT_COUNT-1) begin
                    weight_done <= 1'b1;
                end else begin
                    weight_count <= weight_count + 1'b1;
                end
            end

            if (!block_valid_o && (feature_done || (feature_tvalid && feature_tready && feature_count == FEATURE_COUNT-1)) &&
                (weight_done || (weight_tvalid && weight_tready && weight_count == WEIGHT_COUNT-1))) begin
                block_valid_o <= 1'b1;
            end
        end
    end
endmodule
