# Kiến trúc baseline GEMM accelerator

Baseline hiện tại tập trung vào tính đúng chức năng và khả năng simulate trước tối ưu. Thiết kế hỗ trợ nhân ma trận INT8 signed dạng `C = A x B`, với kích thước tham số `ROWS x K` nhân `K x COLS`.

## Khối chính

1. `MM_in_buffer` nhận hai stream INT8: feature `A` và weight `B`, kiểm tra `last` ở cuối block, đóng gói vào packed bus.
2. `MM_buffer` giữ một block hoàn chỉnh giữa input và compute.
3. `MM` gọi `PE_array` để tính toàn bộ ma trận kết quả ở mức baseline.
4. `MM_out_buffer` serialize từng phần tử `C[row][col]`, dùng `right_shifter` để shift/saturate về INT8.
5. `GEMM_TOP` hiện chỉ wrap AXI-Stream; AXI4-Lite control chưa được triển khai đầy đủ.

## Packed data mapping

Baseline dùng row-major:

- `A[row][k]` nằm tại `features_i[((row*K+k)*DATA_WIDTH)+:DATA_WIDTH]`.
- `B[k][col]` nằm tại `weights_i[((k*COLS+col)*DATA_WIDTH)+:DATA_WIDTH]`.
- `C[row][col]` nằm tại `results_o[((row*COLS+col)*ACC_WIDTH)+:ACC_WIDTH]`.

Ví dụ 2x2: index packed lần lượt là `[0]=[0][0]`, `[1]=[0][1]`, `[2]=[1][0]`, `[3]=[1][1]`.

Ví dụ 4x4: hàng 0 có index 0..3, hàng 1 có index 4..7, hàng 2 có index 8..11, hàng 3 có index 12..15.

## Giới hạn hiện tại

- `PE_array` baseline là mô hình dot-product song song tổ hợp, chưa phải systolic timing-accurate array hoàn chỉnh.
- `MM_ultra` là pipeline tối thiểu để verification, chưa tối ưu throughput.
- AXI4-Lite register map chưa có: **Needs verification/TODO**.
