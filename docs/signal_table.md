# Signal table

| Module | Signal | Dir | Width | Mô tả |
|---|---|---:|---:|---|
| Common | `clk` | in | 1 | Clock. |
| Common | `rst_n` | in | 1 | Reset active-low. |
| `PE` | `feature_i` | in | `DATA_WIDTH` | INT8 signed feature. |
| `PE` | `weight_i` | in | `DATA_WIDTH` | INT8 signed weight. |
| `PE` | `acc_o` | out | `ACC_WIDTH` | Accumulator signed. |
| `MM_in_buffer` | `feature_tdata` | in | `DATA_WIDTH` | Stream feature. |
| `MM_in_buffer` | `feature_tvalid/tready/tlast` | in/out | 1 | Handshake feature. |
| `MM_in_buffer` | `weight_tdata` | in | `DATA_WIDTH` | Stream weight. |
| `MM_in_buffer` | `weight_tvalid/tready/tlast` | in/out | 1 | Handshake weight. |
| `MM_in_buffer` | `protocol_error_o` | out | 1 | Lỗi vị trí last. |
| `MM` | `features_i` | in | `ROWS*K*DATA_WIDTH` | Packed A row-major. |
| `MM` | `weights_i` | in | `K*COLS*DATA_WIDTH` | Packed B row-major. |
| `MM` | `results_o` | out | `ROWS*COLS*ACC_WIDTH` | Packed C row-major. |
| `MM_out_buffer` | `shift_i` | in | `SHIFT_WIDTH` | Arithmetic right shift. |
| `MM_out_buffer` | `out_tdata` | out | `OUT_WIDTH` | INT8 output sau saturation. |
| `MM_out_buffer` | `out_tvalid/tready/tlast` | out/in/out | 1 | Handshake output. |
