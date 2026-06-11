`timescale 1ns/1ps
`include "tb_common.vh"
module tb_PE;
    reg clk = 0; always #5 clk = ~clk;
    reg rst_n, clear, valid_i;
    reg signed [7:0] feature_i, weight_i;
    wire signed [31:0] acc_o;
    wire valid_o;
    integer errors = 0;

    PE dut(.clk(clk), .rst_n(rst_n), .clear(clear), .valid_i(valid_i), .feature_i(feature_i), .weight_i(weight_i), .acc_o(acc_o), .valid_o(valid_o));

    task tick; begin @(posedge clk); #1; end endtask

    initial begin
        $dumpfile("build/tb_PE.vcd"); $dumpvars(0, tb_PE);
        rst_n=0; clear=0; valid_i=0; feature_i=0; weight_i=0;
        tick; tick; rst_n=1; tick;
        `TB_ASSERT_EQ("reset_basic.acc", acc_o, 0)
        feature_i=3; weight_i=4; valid_i=1; tick;
        `TB_ASSERT_EQ("positive_small", acc_o, 12)
        feature_i=-2; weight_i=5; valid_i=1; tick;
        `TB_ASSERT_EQ("signed_negative", acc_o, 2)
        feature_i=-3; weight_i=-4; valid_i=1; tick;
        `TB_ASSERT_EQ("mixed_sign", acc_o, 14)
        clear=1; valid_i=0; tick; clear=0;
        `TB_ASSERT_EQ("clear", acc_o, 0)
        feature_i=8'sd127; weight_i=-8'sd128; valid_i=1; tick;
        `TB_ASSERT_EQ("max_min_int8", acc_o, -16256)
        if (errors == 0) $display("TB_PE SUMMARY PASS"); else $display("TB_PE SUMMARY FAIL errors=%0d", errors);
        $finish(errors == 0 ? 0 : 1);
    end
endmodule
