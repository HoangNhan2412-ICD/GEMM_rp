# Mapping research → project

| Chủ đề research | Mapping trong repo | Việc còn thiếu |
|---|---|---|
| GEMM INT8 | `PE`, `PE_array`, `MM` | Chứng minh overflow/accuracy với kích thước lớn. |
| Systolic array | `PE_line`, `PE_array` baseline | Cần thiết kế wavefront/pipeline đúng nghĩa nếu mục tiêu là systolic timing-accurate. |
| Tiling/data reuse | `MM_in_buffer`, `MM_buffer` | Cần BRAM/FIFO/ping-pong buffer và scheduler. |
| Quantization | `right_shifter`, `MM_out_buffer` | Cần rounding mode, scale/zero-point nếu theo quantization thật. |
| Streaming protocol | `valid/ready/last` trong `MM_ultra` | Cần test protocol nhiều block/reset giữa giao dịch. |
| KV260 flow | `constraints/kv260_core.xdc`, scripts Vivado | Cần chạy Vivado thật và cập nhật report. |
