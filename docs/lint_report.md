# Lint report

## Command

```bash
scripts/run_lint.sh
```

## Kết quả hiện tại

- Môi trường kiểm tra không có `verilator` hoặc `iverilog` trong `PATH`.
- Lint HDL chưa chạy được: **Needs verification**.

## Hành động tiếp theo

Cài Verilator hoặc Icarus rồi chạy `scripts/run_lint.sh`. Nếu có warning width/signed/reset, cập nhật lại file này bằng log thật.
