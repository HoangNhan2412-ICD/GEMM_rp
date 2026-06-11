# AGENTS.md

## 0. Ngôn ngữ và vai trò

Bạn là coding/research agent cho một project FPGA/Verilog về GEMM / Matrix Multiplication accelerator.

- Trả lời và ghi tài liệu chính bằng tiếng Việt.
- Code chính dùng Verilog/SystemVerilog.
- Ưu tiên: đúng chức năng → dễ simulate → dễ debug → có testbench → có tài liệu → sau đó mới tối ưu timing/resource.
- Không bịa số liệu FPGA, timing, resource, FPS, GOPS, LUT, FF, BRAM, DSP, power, board result.
- Nếu chưa chạy tool thật, phải ghi rõ: `Needs verification` hoặc `TODO`.

## 1. Bối cảnh project hiện tại

Project hiện tại có các module RTL chính sau:

- `GEMM_TOP`: top/wrapper cấp cao, có giao tiếp AXI4-Lite và AXI-Stream cho feature/weight/output.
- `MM_ultra`: compute top/pipeline chính, nối 3 khối:
  - `MM_in_buffer`
  - `MM_buffer`
  - `MM_out_buffer`
- `MM_in_buffer`: nhận feature/weight stream, xử lý ready/valid/last, chuyển dữ liệu vào compute buffer.
- `MM_buffer`: lưu feature/weight, điều phối dữ liệu vào core nhân ma trận.
- `MM`: compute wrapper quanh PE array.
- `PE_array`: mảng PE theo hàng/cột.
- `PE_line`: một hàng PE.
- `PE`: processing element, nhân cộng signed INT8.
- `AdderS`: cộng vector/partial sum.
- `right_shifter`: shift/quantization/saturation output.
- `MM_out_buffer`: nhận partial sum/compute output, shift và xuất kết quả.

Nếu trong repo còn thiếu dependency, ví dụ AXI wrapper/IP hoặc file test script, không được tự đoán. Hãy ghi rõ file/module còn thiếu và đề xuất cách bổ sung.

## 2. Quy tắc Git/GitHub

- Không sửa trực tiếp `main` hoặc `master`.
- Mỗi nhóm việc phải tạo branch riêng, ví dụ:
  - `codex/rtl-baseline-verification`
  - `codex/interface-protocol-docs`
  - `codex/extended-testbench`
  - `codex/kv260-vivado-flow`
  - `codex/research-report-draft`
- Mỗi Pull Request phải có:
  - mục tiêu
  - file đã sửa/tạo
  - test đã chạy
  - kết quả PASS/FAIL
  - phần chưa kiểm chứng
- Không merge tự động.
- Không xóa code cũ nếu chưa giải thích rõ lý do.
- Không đổi top-level interface nếu chưa ghi lý do và impact vào tài liệu.

## 3. Quy tắc code RTL

- Ưu tiên Verilog/SystemVerilog synthesizable.
- Không dùng `#delay` trong RTL synthesizable.
- Không tạo latch ngoài ý muốn.
- Register phải có reset rõ ràng nếu thuộc control/FSM.
- Luôn kiểm tra signed/unsigned cho INT8 và MAC.
- Luôn kiểm tra bit width:
  - input data: signed INT8 nếu phù hợp
  - partial sum/MAC width phải đủ tránh overflow
  - output shift/saturation phải được ghi rõ
- Với every `valid/ready/last`, phải mô tả protocol rõ.
- Với packed bus, phải ghi rõ mapping:
  - bit range nào là phần tử `[row][col]`
  - thứ tự row-major hay column-major
  - ví dụ cụ thể với 2x2 và 4x4
- Không thay đổi thuật toán chính khi chỉ đang fix lint/sim, trừ khi có lý do rõ.

## 4. Quy tắc testbench và testcase chuẩn NCKH

Mỗi testbench phải có:

- Clock/reset.
- Test reset behavior.
- Test input hợp lệ cơ bản.
- Reference/golden model rõ ràng.
- PASS/FAIL rõ ràng trên console.
- Waveform dump nếu dùng Icarus/GTKWave:
  - `$dumpfile`
  - `$dumpvars`
- Testcase phải có tên và mô tả.

Các testcase tối thiểu:

1. `reset_basic`: reset xong output/control ở trạng thái an toàn.
2. `zero_matrix`: feature/weight toàn 0, output phải 0.
3. `identity_matrix`: nhân với ma trận identity nếu interface phù hợp.
4. `positive_small`: số dương nhỏ, tính tay được.
5. `signed_negative`: có số âm INT8.
6. `mixed_sign`: trộn âm/dương.
7. `max_min_int8`: kiểm tra biên INT8, overflow/MAC width.
8. `shift_quantization`: kiểm tra `right_shifter`/shift/saturation.
9. `backpressure_ready_valid`: stall `ready`, giữ `valid`, kiểm tra không mất dữ liệu.
10. `last_protocol`: kiểm tra `last` ở cuối frame/block.
11. `random_fixed_seed`: random có seed cố định và golden model.
12. `multi_block`: nhiều block feature/weight nếu interface hỗ trợ.
13. `reset_mid_transaction`: reset giữa giao dịch nếu thiết kế yêu cầu chịu được.

Không được gọi test “hoàn hảo” nếu chưa có coverage rõ. Nếu chưa đủ coverage, ghi là `baseline` hoặc `extended regression`.

## 5. Thứ tự verification ưu tiên

Ưu tiên test từ nhỏ đến lớn:

1. Unit test:
   - `PE`
   - `PE_line`
   - `PE_array`
   - `right_shifter`
   - `AdderS`
2. Buffer/protocol test:
   - `MM_in_buffer`
   - `MM_buffer`
   - `MM_out_buffer`
3. Integration test:
   - `MM`
   - `MM_ultra`
4. Full wrapper test:
   - `GEMM_TOP` nếu đầy đủ AXI/IP/dependency.

Nếu `GEMM_TOP` thiếu AXI wrapper/IP hoặc khó test ngay, không được bịa. Hãy test `MM_ultra` trước và ghi rõ `GEMM_TOP requires AXI integration test`.

## 6. Script automation cần có

Nếu có thể, tạo/cập nhật các script sau:

- `scripts/run_lint.sh`
- `scripts/run_lint.bat`
- `scripts/run_sim.sh`
- `scripts/run_sim.bat`
- `scripts/run_regression.sh`
- `scripts/run_regression.bat`
- `scripts/run_vivado_kv260.tcl`
- `scripts/run_synth_kv260.sh`
- `scripts/run_synth_kv260.bat`
- `scripts/parse_vivado_reports.py`
- `scripts/gen_test_vectors.py`

Nếu môi trường không có tool, không bịa kết quả. Hãy ghi command cần chạy.

Tool ưu tiên:

- Icarus Verilog cho simulation cơ bản.
- Verilator cho lint.
- Vivado cho synthesis/timing/resource.
- GTKWave/Vivado GUI chỉ dùng để review waveform thủ công nếu cần.

## 7. KV260 synthesis/timing/resource flow

Target chính:

- Board mục tiêu: AMD/Xilinx Kria KV260.
- Device/part core synthesis: `xck26-sfvc784-2LV-c` nếu không dùng board flow.
- Dùng constraint clock cơ bản trước, ví dụ 100 MHz:
  - `create_clock -period 10.000 -name clk [get_ports clk]`

Vivado automation phải tạo report:

- `reports/kv260/post_synth_utilization.rpt`
- `reports/kv260/post_synth_timing_summary.rpt`
- `reports/kv260/post_impl_utilization.rpt`
- `reports/kv260/post_impl_timing_summary.rpt`
- `reports/kv260/post_impl_power.rpt`
- `reports/kv260/post_impl_drc.rpt`

Chỉ được ghi số liệu resource/timing nếu report Vivado thật sự tồn tại và được parse từ file report.

## 8. Tài liệu bắt buộc

Tạo/cập nhật các file docs sau khi phù hợp:

- `docs/architecture.md`
- `docs/module_hierarchy.md`
- `docs/interface_protocol.md`
- `docs/signal_table.md`
- `docs/parameter_table.md`
- `docs/dataflow.md`
- `docs/fsm.md`
- `docs/verification_plan.md`
- `docs/testcase_matrix.md`
- `docs/simulation_report.md`
- `docs/lint_report.md`
- `docs/synthesis_report.md`
- `docs/timing_report.md`
- `docs/resource_report.md`
- `docs/change_log.md`
- `docs/known_issues.md`
- `docs/todo.md`

Tài liệu phải phân biệt rõ:

- Đã chạy simulation.
- Đã chạy lint.
- Đã chạy synthesis.
- Đã chạy implementation.
- Chưa chạy/chưa kiểm chứng.

## 9. Sơ đồ

Tạo Mermaid trong `docs/diagrams.md` gồm:

1. Sơ đồ module hierarchy.
2. Sơ đồ dataflow:
   - external input
   - `MM_in_buffer`
   - `MM_buffer`
   - `MM`
   - `PE_array`
   - `MM_out_buffer`
   - external output
3. Sơ đồ valid/ready/last protocol.
4. Sơ đồ FSM nếu tìm thấy FSM.
5. Nếu có AXI ở `GEMM_TOP`, tạo sơ đồ AXI4-Lite control và AXI-Stream data.

Không vẽ sơ đồ sai chắc chắn. Nếu chưa chắc, ghi rõ giả định.

## 10. Research report / paper writing rules

Mục tiêu là viết report nghiên cứu chi tiết theo chuẩn NCKH về FPGA GEMM accelerator.

Tạo/cập nhật:

- `research/related_work.md`
- `research/fpga_recent_papers.md`
- `research/paper_comparison_table.md`
- `research/research_to_project_mapping.md`
- `paper/report_draft_vi.md`
- `paper/outline.md`
- `paper/references.bib` nếu có citation chuẩn.

Quy tắc research:

- Không bịa paper.
- Không bịa citation.
- Không bịa DOI/link.
- Không bịa số liệu performance.
- Chỉ dùng số liệu nếu có nguồn kiểm chứng.
- Nếu không có internet access, tạo template và search query, không tự bịa nội dung.

Cấu trúc report khuyến nghị:

1. Tóm tắt.
2. Giới thiệu.
3. Bối cảnh và động lực.
4. Cơ sở lý thuyết:
   - GEMM
   - INT8 quantization
   - systolic array
   - data reuse
   - tiling
   - valid/ready streaming
5. Related work.
6. Kiến trúc đề xuất.
7. Thiết kế module:
   - `MM_in_buffer`
   - `MM_buffer`
   - `MM`
   - `PE_array`
   - `PE_line`
   - `PE`
   - `MM_out_buffer`
   - `GEMM_TOP`
8. Phương pháp kiểm chứng.
9. Testcase và kết quả simulation.
10. Synthesis/timing/resource trên KV260 nếu đã có.
11. Thảo luận.
12. Hạn chế.
13. Kết luận và hướng phát triển.

## 11. Definition of Done

Một task chỉ được xem là xong khi có:

- Danh sách file đã sửa/tạo.
- Lệnh đã chạy.
- Kết quả PASS/FAIL.
- Report tương ứng.
- Known issues nếu còn.
- Không có claim chưa kiểm chứng.
- PR summary rõ ràng.

Nếu không chạy được tool, task vẫn có thể hoàn thành ở mức `setup/template`, nhưng phải ghi rõ chưa có kết quả thực nghiệm.
