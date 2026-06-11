# DSP experiment plan

## Mục tiêu

Điều tra vì sao baseline `GEMM_TOP` trên KV260/K26 đã verified `DSP = 0` dù RTL có phép nhân INT8. Task này chỉ tạo flow experiment và tài liệu; **không sửa RTL chính** và **không dùng** `(* use_dsp = "yes" *)` trong RTL chính.

## Baseline đã verified để đối chiếu

| Metric | Value | Nguồn |
|---|---:|---|
| LUT | `4706` | `reports/kv260/post_impl_utilization.rpt` |
| FF | `1119` | `reports/kv260/post_impl_utilization.rpt` |
| BRAM | `0` | `reports/kv260/post_impl_utilization.rpt` |
| DSP | `0` | `reports/kv260/post_synth_utilization.rpt` và `reports/kv260/post_impl_utilization.rpt` |
| WNS | `4.021 ns` | `reports/kv260/post_impl_timing_summary.rpt` |
| TNS | `0.000 ns` | `reports/kv260/post_impl_timing_summary.rpt` |
| WHS | `0.030 ns` | `reports/kv260/post_impl_timing_summary.rpt` |
| THS | `0.000 ns` | `reports/kv260/post_impl_timing_summary.rpt` |
| Setup failing endpoints | `0` | `reports/kv260/post_impl_timing_summary.rpt` |
| Hold failing endpoints | `0` | `reports/kv260/post_impl_timing_summary.rpt` |
| Timing status | `All user specified timing constraints are met.` | `reports/kv260/post_impl_timing_summary.rpt` |

## Top cần synthesize riêng

Flow experiment synthesize từng top sau, mỗi top ghi report riêng vào `reports/dsp_experiments/<top_name>/`:

1. `PE`
2. `PE_array`
3. `MM`
4. `MM_ultra`
5. `GEMM_TOP`

## Metric cần parse

Bắt buộc parse cho từng top khi report tồn tại:

- `LUT`
- `FF`
- `BRAM`
- `DSP`
- `WNS`
- `TNS`

Flow cũng probe thêm:

- số cell primitive có `REF_NAME =~ DSP*`
- số cell có tên liên quan `mult` hoặc `product`

## Lệnh chạy

Linux/Vivado trong `PATH`:

```bash
scripts/run_dsp_experiments.sh
```

Windows Vivado 2022.2:

```bat
scripts\run_dsp_experiments.bat
```

Chỉ parse lại report và cập nhật tài liệu:

```bash
python3 scripts/parse_dsp_experiments.py --write-doc
```

## File report được tạo cho mỗi top

Trong `reports/dsp_experiments/<top_name>/`:

- `post_synth_utilization.rpt`
- `post_synth_utilization_hier.rpt`
- `post_synth_timing_summary.rpt`
- `dsp_cell_probe.rpt`
- `post_synth.dcp`

Tổng hợp JSON được ghi vào `reports/dsp_experiments/summary.json`. Báo cáo Markdown được cập nhật tại `docs/dsp_experiment_report.md`.

## Giả thuyết cần kiểm chứng

| Giả thuyết | Cách kiểm tra bằng experiment |
|---|---|
| Multiplier INT8 bị Vivado map sang LUT | `PE`/`PE_array` có multiplier/product-named cells nhưng `DSP = 0`. |
| Compute path bị optimize | Multiplier/product-named cells biến mất ở `MM_ultra` hoặc `GEMM_TOP`, đặc biệt khi so với `PE_array`/`MM`. |
| Top baseline chưa đi qua `PE` registered MAC | `PE` có đặc trưng MAC riêng nhưng `PE_array`/`MM`/`GEMM_TOP` đi theo dot-product combinational, không instantiate `PE`. |
| Coding style chưa infer DSP48 | `PE_array`/`MM` vẫn có phép nhân nhưng `DSP = 0`; cần xem hierarchical utilization/schematic trước khi sửa RTL. |

## Quy tắc về `use_dsp`

Không thêm `(* use_dsp = "yes" *)` vào RTL chính trong task này. Nếu cần thử `use_dsp`, tạo branch experiment riêng hoặc RTL wrapper/thư mục experiment riêng, ghi rõ experimental, chạy lại simulation/lint trước khi so sánh synthesis.

## Trạng thái hiện tại

Flow và parser đã sẵn sàng, nhưng trong môi trường agent hiện không có Vivado nên chưa có số liệu experiment thật. Kết quả cho từng top trong `docs/dsp_experiment_report.md` vẫn là **Needs verification** cho tới khi chạy trên máy có Vivado.
