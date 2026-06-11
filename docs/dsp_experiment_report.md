# DSP experiment report

## Mục tiêu

Flow này synthesize riêng các top `PE`, `PE_array`, `MM`, `MM_ultra`, `GEMM_TOP` để điều tra vì sao baseline `GEMM_TOP` verified `DSP = 0` trên KV260/K26. RTL chính không bị sửa và flow này không dùng `(* use_dsp = "yes" *)`.

 codex/create-research-grade-automation-project-5wi553
Kế hoạch chi tiết, giả thuyết cần kiểm chứng và quy tắc về `use_dsp` được ghi trong `docs/dsp_experiment_plan.md`.

main
## Cách chạy

Linux/Vivado trong PATH:

```bash
scripts/run_dsp_experiments.sh
```

Windows Vivado 2022.2:

```bat
scripts\run_dsp_experiments.bat
```

Report từng top được ghi vào `reports/dsp_experiments/<top_name>/`. Sau khi có report thật, chạy lại parser nếu cần:

```bash
python3 scripts/parse_dsp_experiments.py --write-doc
```

## Bảng so sánh

| Top | LUT | FF | BRAM | DSP | WNS | TNS | DSP primitive cells | Mult/product named cells | Trọng tâm kiểm tra |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| `PE` | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Kiểm tra MAC registered INT8 đơn lẻ (`feature_i * weight_i` cộng accumulator). |
| `PE_array` | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Kiểm tra dot-product combinational có nhiều multiplier INT8 trong compute core baseline. |
| `MM` | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Kiểm tra wrapper registered quanh `PE_array`; xác định multiplier có còn trong cone `MM` không. |
| `MM_ultra` | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Kiểm tra pipeline input/buffer/MM/output; xác định compute path có bị optimize qua stream control không. |
| `GEMM_TOP` | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | Needs verification | So sánh với baseline top wrapper đã verified DSP = 0. |

## Baseline verified để đối chiếu

Baseline `GEMM_TOP` implementation đã verified trước đó trên KV260/K26: LUT = 4706, FF = 1119, BRAM = 0, DSP = 0, WNS = 4.021 ns, TNS = 0.000 ns, WHS = 0.030 ns, THS = 0.000 ns, setup failing endpoints = 0, hold failing endpoints = 0, timing status `All user specified timing constraints are met.`

## Diễn giải dự kiến

- Nếu `PE` có DSP > 0 nhưng `PE_array`/`MM`/`GEMM_TOP` vẫn DSP = 0, khả năng compute path hiện tại không đi qua MAC registered `PE` trong top baseline.
- Nếu `PE_array` và `MM` đều DSP = 0 trong khi vẫn có multiplier/product-named cells, khả năng Vivado map multiplier INT8 nhỏ sang LUT hoặc coding style combinational chưa infer DSP48.
- Nếu multiplier/product-named cells biến mất ở `MM_ultra` hoặc `GEMM_TOP`, cần kiểm tra stream/control và visibility để xem compute path có bị optimize không.
- Không kết luận nguyên nhân cuối cùng nếu chưa có report thật trong `reports/dsp_experiments/`; ghi `Needs verification` cho kết quả chưa chạy.

## Trạng thái

Chưa có report Vivado thật trong `reports/dsp_experiments/` tại thời điểm tạo tài liệu này. Cần chạy flow trên máy có Vivado. **Needs verification**.
