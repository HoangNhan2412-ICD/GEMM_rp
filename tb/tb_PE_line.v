`timescale 1ns/1ps
`include "tb_common.vh"
module tb_PE_line;
    reg clk=0; always #5 clk=~clk;
    reg rst_n, clear, valid_i;
    reg signed [7:0] feature_i;
    reg signed [15:0] weights_i;
    wire signed [63:0] accs_o;
    wire [1:0] valids_o;
    integer errors = 0;
    PE_line #(.COLS(2), .DATA_WIDTH(8), .ACC_WIDTH(32)) dut(.clk(clk), .rst_n(rst_n), .clear(clear), .valid_i(valid_i), .feature_i(feature_i), .weights_i(weights_i), .accs_o(accs_o), .valids_o(valids_o));
    task tick; begin @(posedge clk); #1; end endtask
    initial begin
        $dumpfile("build/tb_PE_line.vcd"); $dumpvars(0, tb_PE_line);
        rst_n=0; clear=0; valid_i=0; feature_i=0; weights_i=0; tick; rst_n=1; tick;
        `TB_ASSERT_EQ("reset_basic.pe0", accs_o[31:0], 0)
        feature_i=3; weights_i={8'sd5,8'sd4}; valid_i=1; tick;
        `TB_ASSERT_EQ("positive_small.pe0", accs_o[31:0], 12)
        `TB_ASSERT_EQ("positive_small.pe1", accs_o[63:32], 15)
        if (errors == 0) $display("TB_PE_LINE SUMMARY PASS"); else $display("TB_PE_LINE SUMMARY FAIL errors=%0d", errors);
        $finish(errors == 0 ? 0 : 1);
    end
endmodule
