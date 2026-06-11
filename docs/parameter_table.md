# Parameter table

| Parameter | Default | Module | Ý nghĩa |
|---|---:|---|---|
| `ROWS` | 4 | `PE_array`, `MM`, `MM_ultra`, buffers | Số hàng ma trận A/C. |
| `COLS` | 4 | `PE_array`, `MM`, `MM_ultra`, buffers | Số cột ma trận B/C. |
| `K` | 4 | `PE_array`, `MM`, `MM_ultra`, buffers | Chiều tích lũy dot-product. |
| `DATA_WIDTH` | 8 | hầu hết module | Độ rộng feature/weight signed INT8. |
| `ACC_WIDTH` | 32 | compute/output | Độ rộng accumulator signed. |
| `OUT_WIDTH` | 8 | output | Độ rộng kết quả quantized. |
| `SHIFT_WIDTH` | 5 | `right_shifter`, output | Độ rộng cấu hình shift. |
| `LANES` | 4 | `AdderS` | Số lane packed cần cộng. |

`ACC_WIDTH=32` là baseline an toàn cho test nhỏ; cần phân tích overflow chính thức khi tăng kích thước: **Needs verification**.
