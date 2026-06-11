`timescale 1ns/1ps
`include "tb_common.vh"
module tb_MM_ultra;
    reg clk=0; always #5 clk=~clk;
    reg rst_n;
    reg signed [7:0] feature_tdata, weight_tdata;
    reg feature_tvalid, feature_tlast, weight_tvalid, weight_tlast;
    wire feature_tready, weight_tready;
    reg [4:0] shift_i;
    wire signed [7:0] out_tdata;
    wire out_tvalid, out_tlast;
    reg out_tready;
    wire protocol_error_o;
    integer errors = 0;
    integer out_count;
    reg signed [7:0] out_mem [0:3];

    MM_ultra #(.ROWS(2), .COLS(2), .K(2), .DATA_WIDTH(8), .ACC_WIDTH(32), .OUT_WIDTH(8), .SHIFT_WIDTH(5)) dut(
        .clk(clk), .rst_n(rst_n),
        .feature_tdata(feature_tdata), .feature_tvalid(feature_tvalid), .feature_tready(feature_tready), .feature_tlast(feature_tlast),
        .weight_tdata(weight_tdata), .weight_tvalid(weight_tvalid), .weight_tready(weight_tready), .weight_tlast(weight_tlast),
        .shift_i(shift_i), .out_tdata(out_tdata), .out_tvalid(out_tvalid), .out_tready(out_tready), .out_tlast(out_tlast), .protocol_error_o(protocol_error_o));

    task tick; begin @(posedge clk); #1; end endtask
    task reset_dut; begin
        rst_n=0; feature_tdata=0; weight_tdata=0; feature_tvalid=0; weight_tvalid=0; feature_tlast=0; weight_tlast=0; shift_i=0; out_tready=1; out_count=0;
        tick; tick; rst_n=1; tick;
    end endtask
    task send_pair(input signed [7:0] a, input signed [7:0] b, input integer idx); begin
        feature_tdata=a; weight_tdata=b; feature_tvalid=1; weight_tvalid=1; feature_tlast=(idx==3); weight_tlast=(idx==3);
        while (!(feature_tready && weight_tready)) tick;
        tick;
        feature_tvalid=0; weight_tvalid=0; feature_tlast=0; weight_tlast=0;
    end endtask
    task collect_outputs(input integer stall_first); begin
        out_count=0;
        if (stall_first) begin out_tready=0; repeat(3) tick; out_tready=1; end
        while (out_count < 4) begin
            if (out_tvalid && out_tready) begin
                out_mem[out_count] = out_tdata;
                if ((out_count == 3) && !out_tlast) begin $display("FAIL last_protocol: missing last"); errors=errors+1; end
                if ((out_count != 3) && out_tlast) begin $display("FAIL last_protocol: early last"); errors=errors+1; end
                out_count = out_count + 1;
            end
            tick;
        end
    end endtask

    initial begin
        $dumpfile("build/tb_MM_ultra.vcd"); $dumpvars(0, tb_MM_ultra);
        reset_dut;
        `TB_ASSERT_EQ("reset_basic.valid", out_tvalid, 0)
        send_pair(0,0,0); send_pair(0,0,1); send_pair(0,0,2); send_pair(0,0,3); collect_outputs(0);
        `TB_ASSERT_EQ("zero_matrix.c00", out_mem[0], 0)
        reset_dut;
        send_pair(1,1,0); send_pair(2,0,1); send_pair(3,0,2); send_pair(4,1,3); collect_outputs(0);
        `TB_ASSERT_EQ("identity_matrix.c00", out_mem[0], 1)
        `TB_ASSERT_EQ("identity_matrix.c01", out_mem[1], 2)
        `TB_ASSERT_EQ("identity_matrix.c10", out_mem[2], 3)
        `TB_ASSERT_EQ("identity_matrix.c11", out_mem[3], 4)
        reset_dut;
        send_pair(1,-1,0); send_pair(2,2,1); send_pair(3,3,2); send_pair(4,-4,3); collect_outputs(1);
        `TB_ASSERT_EQ("backpressure_ready_valid.c00", out_mem[0], 5)
        `TB_ASSERT_EQ("mixed_sign.c01", out_mem[1], -6)
        reset_dut;
        shift_i=1; send_pair(100,2,0); send_pair(100,2,1); send_pair(100,2,2); send_pair(100,2,3); collect_outputs(0);
        `TB_ASSERT_EQ("shift_quantization.saturate", out_mem[0], 127)
        reset_dut;
        send_pair(8'sd127,-8'sd128,0); send_pair(8'sd0,8'sd0,1); send_pair(8'sd0,8'sd0,2); send_pair(8'sd0,8'sd0,3); collect_outputs(0);
        `TB_ASSERT_EQ("max_min_int8.saturate", out_mem[0], -128)
        if (errors == 0) $display("TB_MM_ULTRA SUMMARY PASS"); else $display("TB_MM_ULTRA SUMMARY FAIL errors=%0d", errors);
        $finish(errors == 0 ? 0 : 1);
    end
endmodule
