`timescale 1ns/1ps
`include "tb_common.vh"
module tb_PE_array;
    reg signed [(2*2*8)-1:0] features_i;
    reg signed [(2*2*8)-1:0] weights_i;
    wire signed [(2*2*32)-1:0] results_o;
    integer errors = 0;
    PE_array #(.ROWS(2), .COLS(2), .K(2), .DATA_WIDTH(8), .ACC_WIDTH(32)) dut(.features_i(features_i), .weights_i(weights_i), .results_o(results_o));
    task set_a(input integer idx, input signed [7:0] val); begin features_i[(idx*8)+:8] = val; end endtask
    task set_b(input integer idx, input signed [7:0] val); begin weights_i[(idx*8)+:8] = val; end endtask
    function signed [31:0] c(input integer idx); begin c = results_o[(idx*32)+:32]; end endfunction
    initial begin
        $dumpfile("build/tb_PE_array.vcd"); $dumpvars(0, tb_PE_array);
        features_i=0; weights_i=0; #1; `TB_ASSERT_EQ("zero_matrix.c00", c(0), 0)
        // A = [[1,2],[3,4]], B = identity
        set_a(0,1); set_a(1,2); set_a(2,3); set_a(3,4);
        set_b(0,1); set_b(1,0); set_b(2,0); set_b(3,1); #1;
        `TB_ASSERT_EQ("identity_matrix.c00", c(0), 1)
        `TB_ASSERT_EQ("identity_matrix.c01", c(1), 2)
        `TB_ASSERT_EQ("identity_matrix.c10", c(2), 3)
        `TB_ASSERT_EQ("identity_matrix.c11", c(3), 4)
        // B = [[-1,2],[3,-4]] => C=[5,-6;9,-10]
        set_b(0,-1); set_b(1,2); set_b(2,3); set_b(3,-4); #1;
        `TB_ASSERT_EQ("mixed_sign.c00", c(0), 5)
        `TB_ASSERT_EQ("mixed_sign.c01", c(1), -6)
        `TB_ASSERT_EQ("mixed_sign.c10", c(2), 9)
        `TB_ASSERT_EQ("mixed_sign.c11", c(3), -10)
        if (errors == 0) $display("TB_PE_ARRAY SUMMARY PASS"); else $display("TB_PE_ARRAY SUMMARY FAIL errors=%0d", errors);
        $finish(errors == 0 ? 0 : 1);
    end
endmodule
