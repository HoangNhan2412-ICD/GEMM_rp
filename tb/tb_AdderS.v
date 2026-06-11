`timescale 1ns/1ps
`include "tb_common.vh"
module tb_AdderS;
    reg signed [127:0] data_i;
    wire signed [31:0] sum_o;
    integer errors = 0;
    AdderS #(.LANES(4), .ACC_WIDTH(32)) dut(.data_i(data_i), .sum_o(sum_o));
    initial begin
        $dumpfile("build/tb_AdderS.vcd"); $dumpvars(0, tb_AdderS);
        data_i = {32'sd4, 32'sd3, 32'sd2, 32'sd1}; #1; `TB_ASSERT_EQ("positive_small", sum_o, 10)
        data_i = {32'sd0, -32'sd3, 32'sd2, -32'sd1}; #1; `TB_ASSERT_EQ("mixed_sign", sum_o, -2)
        data_i = 0; #1; `TB_ASSERT_EQ("zero_matrix", sum_o, 0)
        if (errors == 0) $display("TB_ADDERS SUMMARY PASS"); else $display("TB_ADDERS SUMMARY FAIL errors=%0d", errors);
        $finish(errors == 0 ? 0 : 1);
    end
endmodule
