# FSM/control behavior

Không có FSM mã hóa enum phức tạp trong baseline. Control hiện là các cờ trạng thái nhỏ:

## `MM_in_buffer`

- `feature_count`, `weight_count`: đếm phần tử đã nhận.
- `feature_done`, `weight_done`: block input đã đủ.
- `block_valid_o`: block hoàn chỉnh đang chờ downstream accept.
- `protocol_error_o`: latch lỗi `last` sai vị trí.

## `MM_buffer`

- `valid_o`: one-entry elastic buffer có dữ liệu hợp lệ.

## `MM_out_buffer`

- `sending`: đang serialize block output.
- `out_count`: index phần tử output row-major.
- `out_tlast`: assert khi `out_count == ROWS*COLS-1`.

FSM chi tiết hơn cho AXI4-Lite/DMA: **Needs verification/TODO**.
