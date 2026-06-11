# Verification plan

## Mức ưu tiên

1. Unit: `PE`, `PE_line`, `PE_array`, `right_shifter`, `AdderS`.
2. Buffer/protocol: `MM_in_buffer`, `MM_buffer`, `MM_out_buffer`.
3. Integration: `MM`, `MM_ultra`.
4. Full wrapper: `GEMM_TOP` sau khi có AXI4-Lite/register map đầy đủ.

## Testbench baseline đã tạo

- `tb/tb_PE.v`
- `tb/tb_PE_line.v`
- `tb/tb_PE_array.v`
- `tb/tb_right_shifter.v`
- `tb/tb_AdderS.v`
- `tb/tb_MM_ultra.v`

## Tool

- Simulation: `scripts/run_sim.sh` dùng Icarus Verilog nếu có.
- Lint: `scripts/run_lint.sh` dùng Verilator nếu có, fallback Icarus.
- Regression: `scripts/run_regression.sh`.

Trong môi trường hiện tại chưa tìm thấy Icarus/Verilator/Vivado, nên kết quả HDL simulation/lint là **Needs verification**.
