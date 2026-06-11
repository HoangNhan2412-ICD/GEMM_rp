# TODO

- [ ] Chạy `scripts/run_lint.sh` trên máy có Verilator/Icarus và sửa warning/error thật.
- [ ] Chạy `scripts/run_sim.sh` trên máy có Icarus/VVP và cập nhật `docs/simulation_report.md`.
- [ ] Bổ sung unit test riêng cho `MM_in_buffer`, `MM_buffer`, `MM_out_buffer`, `MM`.
- [ ] Bổ sung testcase `multi_block`, `reset_mid_transaction`, random fixed seed trực tiếp trong HDL.
- [ ] Thiết kế AXI4-Lite register map cho `GEMM_TOP` và test wrapper AXI.
- [ ] Chạy Vivado KV260 flow và cập nhật synthesis/timing/resource report bằng số liệu thật.
- [ ] Review/điều chỉnh microarchitecture từ baseline dot-product sang systolic/data-reuse nếu mục tiêu research yêu cầu.
