# Synthesis / implementation report KV260/K26

## Flow đã cấu hình

```bash
scripts/run_synth_kv260.sh
```

Windows Vivado 2022.2:

```bat
scripts\run_synth_kv260.bat
```

`run_synth_kv260.bat` gọi trực tiếp `D:\Vivado\2022.2\bin\vivado.bat` và dừng với lỗi rõ ràng nếu không tìm thấy Vivado.

## Top synthesis hiện tại

Top synthesis hiện tại là `GEMM_TOP`, được đặt trong `scripts/run_vivado_kv260.tcl` bằng biến:

```tcl
set top_name GEMM_TOP
```

`GEMM_TOP` instantiate `MM_ultra`; `MM_ultra` nối pipeline `MM_in_buffer` → `MM_buffer` → `MM` → `MM_out_buffer`; `MM` instantiate `PE_array` cho dot-product baseline.

## Kết quả Vivado thật đã verified

Người dùng đã chạy synthesis/implementation trên Windows và xác nhận đây là kết quả Vivado thật, không phải giả định:

| Metric | Value | Report source | Interpretation |
|---|---:|---|---|
| LUT | `4706` | `post_impl_utilization.rpt` | Resource logic sau implementation. |
| FF | `1119` | `post_impl_utilization.rpt` | Resource register sau implementation. |
| BRAM | `0` | `post_impl_utilization.rpt` | Chưa dùng BRAM trong baseline implementation. |
| DSP | `0` | `post_synth_utilization.rpt` và `post_impl_utilization.rpt` | Đã verified không dùng DSP ở cả synth và impl; nguyên nhân chưa kết luận. |
| Clock | `clk` | `post_impl_timing_summary.rpt` | Clock timing chính. |
| Period | `10.000 ns` | `post_impl_timing_summary.rpt` | Target 100 MHz. |
| WNS | `4.021 ns` | `post_impl_timing_summary.rpt` | Slack setup dương. |
| TNS | `0.000 ns` | `post_impl_timing_summary.rpt` | Không có tổng setup violation. |
| Setup failing endpoints | `0` | `post_impl_timing_summary.rpt` | Không có endpoint setup fail. |
| WHS | `0.030 ns` | `post_impl_timing_summary.rpt` | Slack hold dương. |
| THS | `0.000 ns` | `post_impl_timing_summary.rpt` | Không có tổng hold violation. |
| Hold failing endpoints | `0` | `post_impl_timing_summary.rpt` | Không có endpoint hold fail. |
| Constraint status | `All user specified timing constraints are met.` | `post_impl_timing_summary.rpt` | Baseline implementation đạt timing constraints người dùng đặt. |

## Kết luận synthesis/implementation

Baseline implementation của top `GEMM_TOP` **đạt timing 100 MHz** theo `reports/kv260/post_impl_timing_summary.rpt` thật. Không công bố power vì chưa đọc/ghi nhận giá trị từ `post_impl_power.rpt` thật trong task này.

## Ghi chú về compute path và DSP = 0

- Compute path của top `GEMM_TOP` đi tới `PE_array` thông qua `MM_ultra` và `MM`.
- Trong top hiện tại, `PE_array` có phép nhân signed combinational `product = a * b` cho dot-product baseline.
- Module `PE` cũng có MAC signed registered, nhưng top `GEMM_TOP` hiện **không instantiate `PE`/`PE_line` trực tiếp**; `PE`/`PE_line` chỉ được dùng trong testbench/unit-level hoặc nếu top tương lai nối vào. Vì vậy synthesis top `GEMM_TOP` chủ yếu kiểm chứng compute path trong `PE_array`, không phải mảng PE registered dạng systolic wavefront.
- `DSP = 0` đã verified ở cả post-synthesis và post-implementation, nhưng nguyên nhân chưa kết luận. Cần kiểm chứng bằng utilization theo hierarchy, schematic/netlist hoặc report cell primitive trước khi sửa RTL. Trạng thái nguyên nhân: **Needs verification**.

Kế hoạch kiểm chứng/đề xuất tối ưu DSP được ghi trong `docs/dsp_inference_plan.md`; chưa sửa kiến trúc RTL trong task này.
