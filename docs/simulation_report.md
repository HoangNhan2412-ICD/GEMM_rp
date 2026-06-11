# Simulation report

## Command

```bash
scripts/run_sim.sh
```

## Kết quả hiện tại

- Môi trường kiểm tra không có `iverilog`/`vvp` trong `PATH`.
- Simulation HDL chưa chạy được: **Needs verification**.
- Testbench đã có PASS/FAIL console và dump VCD vào `build/*.vcd` khi chạy được.

## Testbench baseline

- `tb_PE`
- `tb_PE_line`
- `tb_PE_array`
- `tb_right_shifter`
- `tb_AdderS`
- `tb_MM_ultra`

## Vivado xsim trên Windows

```bat
scripts\run_sim_vivado.bat
```

Script này dùng `D:\Vivado\2022.2\bin\xvlog.bat`, `xelab.bat`, `xsim.bat`; kết quả vẫn **Needs verification** cho đến khi chạy trên máy Windows có Vivado.
