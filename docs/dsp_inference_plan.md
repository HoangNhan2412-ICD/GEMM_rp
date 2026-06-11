# DSP inference plan cho GEMM INT8 baseline

## Mục tiêu

Giải thích và kiểm chứng vì sao Vivado report hiện tại cho `DSP = 0`, đồng thời đề xuất hướng ép/infer DSP an toàn nếu mục tiêu nghiên cứu cần dùng DSP48 thay vì LUT multiplier.

## Hiện trạng đã verified

- Top synthesis trong flow KV260 hiện tại: `GEMM_TOP`.
- `GEMM_TOP` instantiate `MM_ultra`.
- `MM_ultra` instantiate `MM`.
- `MM` instantiate `PE_array`.
- `PE_array` hiện là dot-product combinational baseline và có phép nhân signed INT8: `product = a * b`.
- `PE` có MAC signed registered (`feature_i * weight_i` cộng vào accumulator), nhưng `PE`/`PE_line` chưa nằm trong cone logic của top `GEMM_TOP` hiện tại.
- Người dùng đã verified từ Vivado thật: `DSP = 0` trong cả `reports/kv260/post_synth_utilization.rpt` và `reports/kv260/post_impl_utilization.rpt`.
- Baseline implementation vẫn đạt timing 100 MHz: WNS = `4.021 ns`, TNS = `0.000 ns`, setup failing endpoints = `0`, WHS = `0.030 ns`, THS = `0.000 ns`, hold failing endpoints = `0`.

## Điểm đã kết luận và chưa kết luận

| Nội dung | Trạng thái |
|---|---|
| DSP usage bằng 0 | **Verified** ở cả post-synthesis và post-implementation utilization report. |
| Timing 100 MHz | **Verified** đạt post-implementation timing; Vivado ghi `All user specified timing constraints are met.` |
| Nguyên nhân chính xác của `DSP = 0` | **Needs verification**; chưa kết luận nếu chưa xem hierarchy/netlist/schematic/cell primitive. |
| Cần sửa RTL ngay không | Không trong task này; chưa sửa RTL/kiến trúc. |

## Giả thuyết cần kiểm chứng

1. Vivado map phép nhân signed 8x8 sang LUT vì kích thước nhỏ và/hoặc strategy mặc định ưu tiên tiết kiệm DSP.
2. Một phần multiplier bị tối ưu do logic điều khiển/output visibility hoặc do synthesis flatten/hierarchy.
3. Coding style combinational trong `PE_array` không khuyến khích inference DSP48 so với pipeline MAC registered.
4. Chưa có attribute `(* use_dsp = "yes" *)` hoặc setting synthesis tương ứng.

Các giả thuyết trên vẫn là **Needs verification** cho đến khi đọc được netlist/utilization hierarchy thật.


## Experiment flow đã thêm

Để kiểm chứng các giả thuyết mà không sửa RTL chính, repo có thêm flow synthesize riêng từng top:

- `PE`
- `PE_array`
- `MM`
- `MM_ultra`
- `GEMM_TOP`

Lệnh chạy trên Linux/Vivado trong PATH:

```bash
scripts/run_dsp_experiments.sh
```

Lệnh chạy trên Windows Vivado 2022.2:

```bat
scripts\run_dsp_experiments.bat
```

Mỗi top xuất report vào `reports/dsp_experiments/<top_name>/`, gồm utilization, hierarchical utilization, timing summary, checkpoint sau synthesis và `dsp_cell_probe.rpt`. Parser tổng hợp kết quả bằng:

```bash
python3 scripts/parse_dsp_experiments.py --write-doc
```

Báo cáo so sánh được ghi tại `docs/dsp_experiment_report.md`. Hiện tại nếu chưa chạy Vivado experiment thì các metric trong bảng experiment là **Needs verification**.

## Checklist kiểm chứng đề xuất

1. Chạy lại Vivado và giữ report/checkpoint:
   ```bat
   scripts\run_synth_kv260.bat
   ```
2. Mở utilization theo hierarchy trong Vivado hoặc sinh thêm report:
   ```tcl
   report_utilization -hierarchical -file reports/kv260/post_synth_utilization_hier.rpt
   report_utilization -hierarchical -file reports/kv260/post_impl_utilization_hier.rpt
   ```
3. Tìm cell multiplier/DSP trong netlist:
   ```tcl
   get_cells -hier -filter {REF_NAME =~ DSP*}
   get_cells -hier -filter {NAME =~ *mult* || NAME =~ *product*}
   ```
4. Kiểm tra schematic của cone `GEMM_TOP/u_mm_ultra/u_mm/u_pe_array`.
5. So sánh synthesis khi đặt top tạm thời là `MM` hoặc `PE_array` để cô lập compute core. Không dùng số liệu này thay thế số liệu top `GEMM_TOP` nếu mục tiêu report là toàn wrapper.

## Hướng tối ưu DSP, chưa áp dụng trong RTL

- Thử attribute có kiểm soát trên tín hiệu/khối multiplier, ví dụ `(* use_dsp = "yes" *)`, nhưng chỉ sau khi có testcase/lint/simulation PASS để đảm bảo không đổi chức năng.
- Cân nhắc pipeline multiplier/adder tree để Vivado infer DSP/MAC tốt hơn và cải thiện timing, nhưng đây là thay đổi kiến trúc đáng kể nên cần branch/PR riêng.
- Cân nhắc đưa compute path về mảng `PE` registered nếu mục tiêu là systolic array timing-accurate thay vì dot-product combinational baseline.

## Trạng thái

Chưa sửa RTL. Tài liệu này chỉ là kế hoạch điều tra và tối ưu. `DSP = 0` là **verified**, nhưng nguyên nhân cuối cùng của việc không infer DSP vẫn là **Needs verification**.
