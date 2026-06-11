# Change log

## codex/research-grade-automation

- Tạo baseline RTL synthesizable cho pipeline GEMM INT8: `PE`, `PE_line`, `PE_array`, `AdderS`, `right_shifter`, `MM`, `MM_in_buffer`, `MM_buffer`, `MM_out_buffer`, `MM_ultra`, `GEMM_TOP`.
- Tạo testbench baseline có PASS/FAIL và VCD dump cho các unit/integration quan trọng.
- Tạo script lint/simulation/regression và flow Vivado KV260.
- Tạo tài liệu kiến trúc, protocol, dataflow, FSM, testcase, report template và draft nghiên cứu tiếng Việt.

Chưa thay đổi interface top-level từ IP có sẵn vì repo ban đầu không có RTL/IP cũ.
