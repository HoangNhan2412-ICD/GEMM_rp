# Báo cáo dự thảo: Bộ gia tốc GEMM INT8 trên FPGA

## 1. Tóm tắt

Đề tài xây dựng baseline bộ gia tốc nhân ma trận GEMM sử dụng dữ liệu INT8 signed trên FPGA. Mục tiêu giai đoạn hiện tại là tạo nền tảng RTL dễ mô phỏng, có testbench, automation lint/simulation, flow Vivado KV260 và tài liệu nghiên cứu. Các kết quả synthesis/timing/resource/FPS/GOPS/power hiện **Needs verification** vì chưa chạy Vivado thật.

## 2. Giới thiệu

GEMM là primitive quan trọng trong CNN, Transformer và nhiều workload học sâu. Trên FPGA, GEMM có thể khai thác song song MAC, data reuse và streaming để giảm độ trễ. Project này chọn hướng thiết kế từng bước: đúng chức năng, có verification baseline, sau đó mới mở rộng tối ưu tài nguyên/timing.

## 3. Động lực nghiên cứu

Các mô hình học sâu thường bị giới hạn bởi cả compute và memory bandwidth. Việc lượng tử INT8 giúp giảm băng thông và tài nguyên tính toán so với FP32, nhưng yêu cầu kiểm soát signed/overflow/quantization rõ ràng. FPGA phù hợp để thử nghiệm kiến trúc PE array, buffer và protocol streaming tùy biến.

## 4. Cơ sở lý thuyết

### GEMM

Với `A` kích thước `M x K` và `B` kích thước `K x N`, GEMM tính `C[m][n] = sum_k A[m][k] * B[k][n]`. Trong RTL baseline, `ROWS=M`, `COLS=N`, `K=K`.

### INT8 quantization

Input feature/weight dùng signed INT8. Accumulator dùng `ACC_WIDTH=32` ở baseline. Output đi qua arithmetic right shift và saturate về INT8 bằng `right_shifter`. Rounding, scale thực và zero-point chưa triển khai: **Needs verification/TODO**.

### Systolic array và PE

Systolic array dùng nhiều PE kết nối đều để tái sử dụng dữ liệu cục bộ. Baseline repo hiện có `PE`, `PE_line`, `PE_array`, nhưng `PE_array` là dot-product baseline, chưa phải wavefront systolic timing-accurate hoàn chỉnh.

### Valid/ready streaming

Handshake `valid/ready` giúp chống mất dữ liệu khi downstream stall. Tín hiệu `last` đánh dấu phần tử cuối block/frame.

## 5. Related work

Các nguồn đã kiểm chứng gồm Systolic Tensor Array (2020), Systolic-CNN (2020), Evaluating Low-Memory GEMMs (FCCM 2020), và High-Frequency Systolic Array-Based Transformer Accelerator (2023). Chi tiết nằm ở `research/related_work.md`. Không lấy số liệu paper để claim hiệu năng project.

## 6. Kiến trúc đề xuất

Pipeline gồm `MM_in_buffer` → `MM_buffer` → `MM`/`PE_array` → `MM_out_buffer`. Input và output đều theo stream valid/ready/last. Dữ liệu packed theo row-major để thuận tiện testbench và golden model.

## 7. Thiết kế module

- `PE`: MAC signed INT8, accumulator reset/clear.
- `PE_line`: nhiều PE dùng chung feature, mỗi PE nhận weight riêng.
- `PE_array`: tính dot-product cho mọi phần tử `C`.
- `AdderS`: cộng nhiều accumulator packed.
- `right_shifter`: shift số học và saturate INT8.
- `MM_in_buffer`: collect feature/weight stream.
- `MM_buffer`: elastic buffer.
- `MM_out_buffer`: serialize kết quả.
- `MM_ultra`: integration top compute pipeline.
- `GEMM_TOP`: wrapper cấp cao, AXI4-Lite TODO.

## 8. Phương pháp kiểm chứng

Testbench baseline có clock/reset, PASS/FAIL, waveform dump và golden/reference expected value cho các case nhỏ. Do môi trường hiện tại thiếu Icarus/Verilator, test chưa chạy thật: **Needs verification**.

## 9. Testcase

Đã tạo testcase cho reset, zero, identity, positive small, signed negative, mixed sign, max/min INT8, shift/quantization, output backpressure, last protocol. `multi_block`, `reset_mid_transaction`, random fixed seed HDL đầy đủ vẫn là TODO.

## 10. KV260 synthesis/timing/resource

Flow Vivado batch nhắm part `xck26-sfvc784-2LV-c`, clock baseline 100 MHz. Chưa chạy Vivado thật, do đó không có số liệu tài nguyên/timing/power hợp lệ: **Needs verification**.

## 11. Hạn chế

- Chưa có AXI4-Lite register map hoàn chỉnh.
- Chưa có BRAM tiling/ping-pong buffer.
- Chưa chạy lint/simulation/synthesis thật trong môi trường hiện tại.
- `PE_array` cần nâng cấp thành systolic timing-accurate nếu đó là mục tiêu nghiên cứu chính.

## 12. Kết luận và hướng phát triển

Repo đã có baseline automation để bắt đầu verification và documentation chuẩn nghiên cứu. Bước tiếp theo là chạy tool thật, sửa lỗi theo log, mở rộng testcase, hoàn thiện AXI wrapper và tối ưu kiến trúc buffer/systolic array cho KV260.
