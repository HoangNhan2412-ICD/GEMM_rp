`timescale 1ns/1ps
// Serializes ROWS*COLS accumulated results through arithmetic shifter/saturator.
module MM_out_buffer #(
    parameter ROWS = 4,
    parameter COLS = 4,
    parameter ACC_WIDTH = 32,
    parameter OUT_WIDTH = 8,
    parameter SHIFT_WIDTH = 5
)(
    input  wire clk,
    input  wire rst_n,
    input  wire valid_i,
    output wire ready_o,
    input  wire signed [(ROWS*COLS*ACC_WIDTH)-1:0] results_i,
    input  wire [SHIFT_WIDTH-1:0] shift_i,
    output reg signed [OUT_WIDTH-1:0] out_tdata,
    output reg out_tvalid,
    input  wire out_tready,
    output reg out_tlast
);
    localparam OUT_COUNT = ROWS*COLS;
    localparam CNT_W = (OUT_COUNT <= 2) ? 1 : $clog2(OUT_COUNT+1);

    reg signed [(ROWS*COLS*ACC_WIDTH)-1:0] results_q;
    reg [CNT_W-1:0] out_count;
    reg sending;
    wire signed [ACC_WIDTH-1:0] selected_acc;
    wire signed [OUT_WIDTH-1:0] shifted_data;

    assign ready_o = !sending;
    assign selected_acc = (!sending && valid_i) ? results_i[0 +: ACC_WIDTH] : results_q[(out_count*ACC_WIDTH) +: ACC_WIDTH];

    right_shifter #(.IN_WIDTH(ACC_WIDTH), .OUT_WIDTH(OUT_WIDTH), .SHIFT_WIDTH(SHIFT_WIDTH)) u_shift (
        .data_i(selected_acc), .shift_i(shift_i), .data_o(shifted_data)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            results_q <= {(ROWS*COLS*ACC_WIDTH){1'b0}};
            out_count <= {CNT_W{1'b0}};
            sending <= 1'b0;
            out_tdata <= {OUT_WIDTH{1'b0}};
            out_tvalid <= 1'b0;
            out_tlast <= 1'b0;
        end else begin
            if (!sending && valid_i) begin
                results_q <= results_i;
                out_count <= {CNT_W{1'b0}};
                sending <= 1'b1;
                out_tvalid <= 1'b1;
                out_tlast <= (OUT_COUNT == 1);
            end else if (out_tvalid && out_tready) begin
                if (out_count == OUT_COUNT-1) begin
                    sending <= 1'b0;
                    out_tvalid <= 1'b0;
                    out_tlast <= 1'b0;
                    out_count <= {CNT_W{1'b0}};
                end else begin
                    out_count <= out_count + 1'b1;
                    out_tlast <= (out_count == OUT_COUNT-2);
                end
            end

            if (sending || (!sending && valid_i)) begin
                out_tdata <= shifted_data;
            end
        end
    end
endmodule
