# Resource report KV260/K26

## Trạng thái nguồn số liệu

Người dùng đã chạy Vivado 2022.2 synthesis/implementation trên Windows và xác nhận số liệu resource thật từ `reports/kv260/post_synth_utilization.rpt` và `reports/kv260/post_impl_utilization.rpt`. Các số liệu dưới đây là kết quả Vivado thật đã verified, không phải giả định.

## Checklist report resource/timing liên quan

| File | Mục đích | Trạng thái |
|---|---|---|
| `reports/kv260/post_synth_utilization.rpt` | Utilization sau synthesis | Verified theo báo cáo người dùng |
| `reports/kv260/post_synth_timing_summary.rpt` | Timing summary sau synthesis | Chưa công bố số liệu chi tiết trong task này |
| `reports/kv260/post_impl_utilization.rpt` | Utilization sau implementation | Verified theo báo cáo người dùng |
| `reports/kv260/post_impl_timing_summary.rpt` | Timing summary sau implementation | Verified: đạt timing 100 MHz |
| `reports/kv260/post_impl_power.rpt` | Power sau implementation | Không bịa power; chưa công bố nếu chưa đọc report |
| `reports/kv260/post_impl_drc.rpt` | DRC sau implementation | Report present đã được xác nhận ở task trước |

## Kết quả resource thật đã verified

| Metric | Value | Report source | Interpretation |
|---|---:|---|---|
| LUT | `4706` | `post_impl_utilization.rpt` | Logic LUT của baseline implementation. |
| FF | `1119` | `post_impl_utilization.rpt` | Flip-flop/register của baseline implementation. |
| BRAM | `0` | `post_impl_utilization.rpt` | Baseline hiện chưa infer/instantiate BRAM. |
| DSP | `0` | `post_synth_utilization.rpt` và `post_impl_utilization.rpt` | Đã verified DSP không được dùng ở cả post-synthesis và post-implementation. Nguyên nhân chưa kết luận. |

## Nhận xét tài nguyên

- `BRAM = 0` phù hợp với baseline RTL hiện tại vì buffer đang dùng register/packed vector nhỏ, chưa instantiate RAM/BRAM rõ ràng.
- `DSP = 0` đã được xác nhận ở cả `post_synth_utilization.rpt` và `post_impl_utilization.rpt`. Tuy nhiên nguyên nhân chính xác vẫn cần kiểm chứng bằng utilization hierarchy, netlist/schematic hoặc report cell primitive. Xem `docs/dsp_inference_plan.md`.
- Không công bố power trong file này vì chưa có giá trị power thật được cung cấp/đọc trong task hiện tại.
