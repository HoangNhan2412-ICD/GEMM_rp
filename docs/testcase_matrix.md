# Testcase matrix

| Testcase | Module/testbench | Trạng thái |
|---|---|---|
| `reset_basic` | `tb_PE`, `tb_PE_line`, `tb_MM_ultra` | Có testcase; Needs verification bằng simulator. |
| `zero_matrix` | `tb_PE_array`, `tb_right_shifter`, `tb_AdderS`, `tb_MM_ultra` | Có testcase; Needs verification. |
| `identity_matrix` | `tb_PE_array`, `tb_MM_ultra` | Có testcase; Needs verification. |
| `positive_small` | `tb_PE`, `tb_PE_line`, `tb_AdderS` | Có testcase; Needs verification. |
| `signed_negative` | `tb_PE` | Có testcase; Needs verification. |
| `mixed_sign` | `tb_PE`, `tb_PE_array`, `tb_AdderS`, `tb_MM_ultra` | Có testcase; Needs verification. |
| `max_min_int8` | `tb_PE`, `tb_MM_ultra` | Có testcase; Needs verification. |
| `shift_quantization` | `tb_right_shifter`, `tb_MM_ultra` | Có testcase; Needs verification. |
| `backpressure_ready_valid` | `tb_MM_ultra` | Có testcase output backpressure; Needs verification. |
| `last_protocol` | `tb_MM_ultra`, `MM_in_buffer` check nội bộ | Có testcase; Needs verification. |
| `random_fixed_seed` | `scripts/gen_test_vectors.py` | Vector generator có seed; chưa tích hợp HDL đầy đủ. |
| `multi_block` | TODO | Needs verification. |
| `reset_mid_transaction` | TODO | Needs verification. |
