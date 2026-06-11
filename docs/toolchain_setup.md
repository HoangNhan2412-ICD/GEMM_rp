# Toolchain setup: Vivado 2022.2 trên Windows

Tài liệu này hướng dẫn chạy automation với Vivado cài tại:

```text
D:\Vivado\2022.2\bin
```

Không có kết quả synthesis/simulation nào được claim nếu chưa chạy tool thật. Mọi số liệu timing/resource/power vẫn là **Needs verification** cho đến khi Vivado sinh report trong `reports/kv260/`.

## 1. Kiểm tra Vivado

Mở **Command Prompt** tại root repo và chạy:

```bat
if exist D:\Vivado\2022.2\bin\vivado.bat (echo Vivado OK) else (echo Vivado MISSING)
D:\Vivado\2022.2\bin\vivado.bat -version
```

Kiểm tra các tool simulation Vivado:

```bat
if exist D:\Vivado\2022.2\bin\xvlog.bat (echo xvlog OK) else (echo xvlog MISSING)
if exist D:\Vivado\2022.2\bin\xelab.bat (echo xelab OK) else (echo xelab MISSING)
if exist D:\Vivado\2022.2\bin\xsim.bat  (echo xsim OK)  else (echo xsim MISSING)
```

Nếu các file `.bat` không tồn tại, cần kiểm tra lại đường dẫn cài Vivado hoặc chỉnh biến `VIVADO_BIN` trong script Windows tương ứng.

## 2. Chạy synthesis/implementation KV260 trên Windows

Script `scripts\run_synth_kv260.bat` gọi trực tiếp:

```text
D:\Vivado\2022.2\bin\vivado.bat
```

Lệnh chạy từ root repo:

```bat
scripts\run_synth_kv260.bat
```

Script sẽ chạy Tcl flow `scripts\run_vivado_kv260.tcl`, nhắm part `xck26-sfvc784-2LV-c`, top `GEMM_TOP`, và tạo report trong `reports\kv260\` nếu Vivado chạy thành công.

Các report kỳ vọng:

- `reports\kv260\post_synth_utilization.rpt`
- `reports\kv260\post_synth_timing_summary.rpt`
- `reports\kv260\post_impl_utilization.rpt`
- `reports\kv260\post_impl_timing_summary.rpt`
- `reports\kv260\post_impl_power.rpt`
- `reports\kv260\post_impl_drc.rpt`

Sau khi có report thật, script gọi `scripts\parse_vivado_reports.py` để tạo summary nếu parse được. Không ghi số liệu thủ công nếu report không tồn tại.

## 3. Chạy simulation bằng Vivado xsim

Script `scripts\run_sim_vivado.bat` dùng trực tiếp:

- `D:\Vivado\2022.2\bin\xvlog.bat`
- `D:\Vivado\2022.2\bin\xelab.bat`
- `D:\Vivado\2022.2\bin\xsim.bat`

Lệnh chạy từ root repo:

```bat
scripts\run_sim_vivado.bat
```

Script compile `rtl\*.v` và `tb\*.v`, sau đó tự tìm các top testbench theo mẫu file `tb\tb_*.v` rồi elaborate/run từng top tương ứng.

Với repo hiện tại, các top được phát hiện kỳ vọng là:

- `tb_AdderS`
- `tb_MM_ultra`
- `tb_PE`
- `tb_PE_array`
- `tb_PE_line`
- `tb_right_shifter`

Nếu không tìm thấy file `tb\tb_*.v`, script sẽ in lỗi và ghi rõ TODO cần bổ sung/cập nhật testbench.

## 4. Trạng thái kiểm chứng hiện tại

Trong môi trường Linux của agent hiện không có Vivado, Icarus hoặc Verilator, nên chưa chạy được synthesis/simulation HDL thật. Trạng thái hiện tại: **Needs verification** trên máy Windows có Vivado 2022.2.
