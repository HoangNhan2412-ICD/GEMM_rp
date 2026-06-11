# Interface protocol

## Clock/reset

- `clk`: clock đồng bộ.
- `rst_n`: reset bất đồng bộ active-low trong baseline RTL.

## Stream input feature/weight

Mỗi stream dùng handshake kiểu valid/ready/last:

- Transfer xảy ra khi `tvalid && tready` tại cạnh lên `clk`.
- Source phải giữ `tdata`, `tvalid`, `tlast` ổn định khi `tvalid=1` và `tready=0`.
- `tlast` phải assert đúng ở phần tử cuối block.
- Feature block có `ROWS*K` phần tử; weight block có `K*COLS` phần tử.
- Nếu `last` sai vị trí, `protocol_error_o` được set và giữ đến reset.

## Stream output

- `out_tvalid && out_tready` xác nhận một phần tử output INT8 đã shift/saturate.
- `out_tlast` assert ở phần tử cuối block `ROWS*COLS`.
- Backpressure được hỗ trợ ở output bằng cách giữ `out_tvalid` khi `out_tready=0`.

## Control/AXI

`GEMM_TOP` hiện dùng `cfg_shift` trực tiếp. AXI4-Lite control register map chưa được triển khai: **Needs verification/TODO**.
