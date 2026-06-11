# Full prompt đưa cho Codex Automation

Đọc `AGENTS.md` trước khi làm bất cứ việc gì.

Bạn là coding/research agent cho project FPGA/Verilog GEMM accelerator của tôi. Tôi muốn biến repo này thành một project có automation chuẩn để phục vụ nghiên cứu khoa học: sửa code, viết testbench, tạo testcase, chạy lint/simulation, chuẩn bị synthesis/timing/resource cho KV260, và viết report chi tiết.

## Quy tắc quan trọng

1. Không sửa trực tiếp `main` hoặc `master`.
2. Tạo branch mới tên: `codex/research-grade-automation`.
3. Không bịa số liệu FPGA, timing, resource, FPS, GOPS, LUT, FF, BRAM, DSP, power, board result.
4. Không bịa paper/citation/link/DOI.
5. Không đổi top-level interface nếu chưa giải thích rõ lý do.
6. Nếu thiếu dependency, thiếu tool, thiếu internet access, hãy ghi rõ `Needs verification`, không tự đoán.
7. Mọi output phải bằng tiếng Việt, code comment có thể tiếng Anh hoặc tiếng Việt nhưng phải nhất quán.

## Phase 0 — Reconnaissance

Hãy đọc toàn bộ repo và tạo báo cáo ban đầu:

- Xác định top module khả thi:
  - `MM_ultra` cho compute pipeline.
  - `GEMM_TOP` cho top/wrapper AXI nếu đầy đủ dependency.
- Liệt kê tất cả module.
- Liệt kê dependency bị thiếu, đặc biệt nếu có module AXI wrapper/IP chưa có trong repo.
- Liệt kê vấn đề có thể ảnh hưởng simulation/lint/synthesis:
  - syntax
  - missing module
  - width mismatch
  - signed/unsigned
  - latch
  - reset
  - handshake valid/ready/last
  - packed bus mapping
  - unsupported SystemVerilog/Verilog construct nếu có.

Tạo/cập nhật:

- `docs/module_hierarchy.md`
- `docs/known_issues.md`
- `docs/todo.md`

## Phase 1 — Documentation architecture

Tạo/cập nhật:

- `docs/architecture.md`
- `docs/interface_protocol.md`
- `docs/signal_table.md`
- `docs/parameter_table.md`
- `docs/dataflow.md`
- `docs/fsm.md`
- `docs/diagrams.md`

Yêu cầu:

- Giải thích rõ vai trò từng module:
  - `GEMM_TOP`
  - `MM_ultra`
  - `MM_in_buffer`
  - `MM_buffer`
  - `MM`
  - `PE_array`
  - `PE_line`
  - `PE`
  - `AdderS`
  - `right_shifter`
  - `MM_out_buffer`
- Giải thích valid/ready/last protocol.
- Giải thích packed bus format.
- Ghi rõ row-major/column-major nếu xác định được.
- Nếu chưa chắc packed mapping, hãy tạo mục `Assumptions / Needs verification`.
- Tạo Mermaid diagrams cho module hierarchy, dataflow, FSM nếu có.

## Phase 2 — Baseline lint/simulation setup

Tạo/cập nhật script:

- `scripts/run_lint.sh`
- `scripts/run_lint.bat`
- `scripts/run_sim.sh`
- `scripts/run_sim.bat`
- `scripts/run_regression.sh`
- `scripts/run_regression.bat`

Ưu tiên:

- Icarus Verilog cho simulation.
- Verilator cho lint.
- Nếu tool không có trong môi trường, vẫn tạo script và ghi hướng dẫn chạy.

Tạo/cập nhật:

- `docs/lint_report.md`
- `docs/simulation_report.md`

## Phase 3 — Testbench và testcase chuẩn NCKH

Viết testbench theo thứ tự:

1. Unit test:
   - `tb_PE`
   - `tb_PE_line`
   - `tb_PE_array`
   - `tb_right_shifter`
   - `tb_AdderS`
2. Buffer/protocol test nếu khả thi:
   - `tb_MM_in_buffer`
   - `tb_MM_buffer`
   - `tb_MM_out_buffer`
3. Integration test:
   - `tb_MM`
   - `tb_MM_ultra`
4. Full wrapper test:
   - `tb_GEMM_TOP` chỉ nếu đủ AXI dependency.

Testcase tối thiểu:

- reset_basic
- zero_matrix
- identity_matrix
- positive_small
- signed_negative
- mixed_sign
- max_min_int8
- shift_quantization
- backpressure_ready_valid
- last_protocol
- random_fixed_seed
- multi_block nếu interface hỗ trợ
- reset_mid_transaction nếu phù hợp

Yêu cầu testbench:

- Có clock/reset.
- Có golden/reference model.
- Có PASS/FAIL riêng cho từng testcase.
- Có summary tổng.
- Có waveform dump.
- Có fixed seed cho random test.
- Nếu test fail, không che lỗi. Ghi rõ lỗi và nguyên nhân.

Tạo/cập nhật:

- `docs/verification_plan.md`
- `docs/testcase_matrix.md`
- `docs/simulation_report.md`

## Phase 4 — Sửa code an toàn

Sau khi có testbench/lint:

- Sửa lỗi syntax.
- Sửa width mismatch.
- Sửa signed/unsigned sai.
- Sửa missing reset/latch nếu có.
- Sửa valid/ready/last protocol nếu test chứng minh lỗi.
- Không tối ưu lớn khi chưa có test bảo vệ.
- Không đổi thuật toán chính nếu chưa giải thích.

Mọi sửa đổi phải ghi vào:

- `docs/change_log.md`

## Phase 5 — KV260 synthesis/timing/resource automation

Tạo/cập nhật:

- `constraints/kv260_core.xdc`
- `scripts/run_vivado_kv260.tcl`
- `scripts/run_synth_kv260.sh`
- `scripts/run_synth_kv260.bat`
- `scripts/parse_vivado_reports.py`
- `docs/synthesis_report.md`
- `docs/timing_report.md`
- `docs/resource_report.md`

Yêu cầu:

- Target KV260/K26.
- Nếu dùng part, dùng `xck26-sfvc784-2LV-c`.
- Clock baseline 100 MHz nếu top có `clk`.
- Chạy synthesis và implementation nếu Vivado có sẵn.
- Xuất report vào `reports/kv260/`.
- Parse các chỉ số:
  - LUT
  - FF
  - BRAM
  - DSP
  - WNS
  - TNS
  - Failing endpoints
  - DRC
  - power nếu có.
- Chỉ ghi số liệu nếu report thật sự tồn tại.
- Nếu không có Vivado, không bịa. Ghi rõ command cần chạy trên máy tôi.

## Phase 6 — Research và report NCKH

Tạo/cập nhật:

- `research/fpga_recent_papers.md`
- `research/related_work.md`
- `research/paper_comparison_table.md`
- `research/research_to_project_mapping.md`
- `paper/outline.md`
- `paper/report_draft_vi.md`
- `paper/references.bib` nếu có citation.

Nội dung research tập trung vào:

- FPGA GEMM accelerator.
- Systolic array.
- INT8 quantization.
- Tiling.
- Memory reuse.
- BRAM/FIFO/ping-pong buffer.
- Transformer/Attention accelerator nếu có liên quan.

Quy tắc:

- Nếu có internet access, tìm nguồn có thể kiểm chứng.
- Ưu tiên paper từ 2020 đến nay.
- Ghi tên paper, năm, nguồn/link, ý tưởng chính, kiến trúc, board nếu có, số liệu nếu có.
- Không tự bịa số liệu.
- Nếu không có internet, tạo template + search query để tôi tự bổ sung.

Cấu trúc report tiếng Việt:

1. Tóm tắt.
2. Giới thiệu.
3. Động lực nghiên cứu.
4. Cơ sở lý thuyết GEMM/INT8/systolic array.
5. Related work.
6. Kiến trúc đề xuất.
7. Thiết kế chi tiết từng module.
8. Luồng dữ liệu và handshake.
9. Phương pháp kiểm chứng.
10. Testcase và kết quả simulation.
11. Synthesis/timing/resource KV260 nếu đã chạy.
12. Phân tích kết quả.
13. Hạn chế.
14. Kết luận và hướng phát triển.

## Phase 7 — Final self-review

Cuối cùng hãy tự review theo checklist:

- Đã đọc `AGENTS.md` chưa?
- Có sửa trực tiếp main/master không?
- Branch hiện tại là gì?
- Đã tạo/sửa file nào?
- Đã chạy lint chưa?
- Đã chạy simulation chưa?
- Có testcase nào PASS/FAIL?
- Có synthesis/timing/resource thật không?
- Có bịa số liệu không?
- Có bịa paper/citation không?
- Top-level interface có bị đổi không?
- Known issues còn lại là gì?
- PR có an toàn để tôi review không?

Commit thay đổi và tạo Pull Request.

Trả lời cuối bằng tiếng Việt, gồm:
1. Tóm tắt việc đã làm.
2. Lệnh đã chạy.
3. Kết quả PASS/FAIL.
4. File đã tạo/sửa.
5. Việc tôi cần kiểm chứng tiếp.
