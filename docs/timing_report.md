# Timing report KV260/K26

## Clock và target

- Clock: `clk`.
- Constraint period: `10.000 ns`.
- Frequency target: `100 MHz`.
- Part synthesis/implementation trong Tcl flow: `xck26-sfvc784-2LV-c`.

## Kết quả post-implementation timing thật

Nguồn số liệu: người dùng đã đọc từ report Vivado thật `reports/kv260/post_impl_timing_summary.rpt`. Đây là số liệu timing thật đã được báo cáo từ Vivado, không phải giả định.

| Metric | Value | Report source | Interpretation |
|---|---:|---|---|
| Clock | `clk` | `post_impl_timing_summary.rpt` | Clock chính của baseline implementation. |
| Period | `10.000 ns` | `post_impl_timing_summary.rpt` / `constraints/kv260_core.xdc` | Target 100 MHz. |
| Frequency | `100 MHz` | Suy ra từ period 10.000 ns | Baseline implementation được kiểm ở 100 MHz. |
| WNS | `4.021 ns` | `post_impl_timing_summary.rpt` | Slack setup dương; timing setup đạt ở 100 MHz. |
| TNS | `0.000 ns` | `post_impl_timing_summary.rpt` | Không có tổng negative slack setup. |
| Setup failing endpoints | `0` | `post_impl_timing_summary.rpt` | Không có endpoint setup fail. |
| WHS | `0.030 ns` | `post_impl_timing_summary.rpt` | Slack hold dương; hold timing đạt. |
| THS | `0.000 ns` | `post_impl_timing_summary.rpt` | Không có tổng hold violation. |
| Hold failing endpoints | `0` | `post_impl_timing_summary.rpt` | Không có endpoint hold fail. |
| Constraint status | `All user specified timing constraints are met.` | `post_impl_timing_summary.rpt` | Vivado xác nhận các timing constraints do người dùng đặt đều đạt. |

## Kết luận timing

Baseline implementation hiện tại **đạt timing 100 MHz** theo `reports/kv260/post_impl_timing_summary.rpt` thật mà người dùng đã cung cấp. Không suy diễn thêm Fmax tối đa; muốn công bố Fmax cần sweep clock hoặc timing analysis riêng.

## Ghi chú chưa công bố

- Chưa công bố số liệu power vì task này chưa đọc/parse nội dung `post_impl_power.rpt` thật.
- Chưa công bố timing ở clock khác 100 MHz.
