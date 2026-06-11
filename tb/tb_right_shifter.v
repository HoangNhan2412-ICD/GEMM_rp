`timescale 1ns/1ps
`include "tb_common.vh"
module tb_right_shifter;
    reg signed [31:0] data_i;
    reg [4:0] shift_i;
    wire signed [7:0] data_o;
    integer errors = 0;
    right_shifter dut(.data_i(data_i), .shift_i(shift_i), .data_o(data_o));
    initial begin
        $dumpfile("build/tb_right_shifter.vcd"); $dumpvars(0, tb_right_shifter);
        data_i=32'sd64; shift_i=0; #1; `TB_ASSERT_EQ("positive_no_shift", data_o, 64)
        data_i=32'sd256; shift_i=1; #1; `TB_ASSERT_EQ("shift_quantization_saturate_pos", data_o, 127)
        data_i=-32'sd512; shift_i=2; #1; `TB_ASSERT_EQ("shift_quantization_neg", data_o, -128)
        data_i=-32'sd33; shift_i=1; #1; `TB_ASSERT_EQ("arithmetic_shift_neg", data_o, -17)
        data_i=32'sd0; shift_i=4; #1; `TB_ASSERT_EQ("zero_matrix", data_o, 0)
        if (errors == 0) $display("TB_RIGHT_SHIFTER SUMMARY PASS"); else $display("TB_RIGHT_SHIFTER SUMMARY FAIL errors=%0d", errors);
        $finish(errors == 0 ? 0 : 1);
    end
endmodule
