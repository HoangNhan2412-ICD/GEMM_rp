# GEMM_rp

Baseline project cho bộ gia tốc GEMM/Matrix Multiplication INT8 trên FPGA, hướng tới quy trình nghiên cứu có tài liệu, testbench, lint/simulation automation và flow Vivado KV260.

## Cấu trúc chính

- `rtl/`: RTL Verilog/SystemVerilog-compatible baseline.
- `tb/`: testbench Icarus Verilog baseline.
- `scripts/`: automation lint, simulation, regression, Vivado KV260, parser report.
- `docs/`: tài liệu kiến trúc, protocol, testcase, report trạng thái.
- `research/`: related work và mapping nghiên cứu.
- `paper/`: draft báo cáo tiếng Việt.
- `constraints/`: XDC baseline cho KV260/K26.

## Lệnh thường dùng

```bash
scripts/run_lint.sh
scripts/run_sim.sh
scripts/run_regression.sh
scripts/run_synth_kv260.sh
```

Nếu thiếu tool (`verilator`, `iverilog`, `vivado`), script sẽ báo `Needs verification` và không bịa kết quả.
