`ifndef TB_COMMON_VH
`define TB_COMMON_VH
`define TB_ASSERT_EQ(NAME, GOT, EXP) \
    if ((GOT) !== (EXP)) begin \
        $display("FAIL %s: got=%0d exp=%0d time=%0t", NAME, $signed(GOT), $signed(EXP), $time); \
        errors = errors + 1; \
    end else begin \
        $display("PASS %s", NAME); \
    end
`endif
