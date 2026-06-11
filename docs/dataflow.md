# Dataflow

1. Host/DMA đưa stream feature và weight vào `MM_ultra`.
2. `MM_in_buffer` nhận `ROWS*K` feature và `K*COLS` weight, lưu vào packed register row-major.
3. `MM_buffer` tạo điểm tách ready/valid giữa input và compute.
4. `MM`/`PE_array` tính `C[row][col] = sum_k A[row][k] * B[k][col]`.
5. `MM_out_buffer` đọc từng accumulator theo row-major, shift số học và saturate về INT8.
6. Output stream xuất `ROWS*COLS` phần tử, assert `out_tlast` ở phần tử cuối.

Baseline này ưu tiên dễ kiểm chứng. Tối ưu tiling, ping-pong buffer, data reuse BRAM/FIFO vẫn là TODO.
