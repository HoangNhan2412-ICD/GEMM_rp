# Module hierarchy

Trạng thái recon: repo ban đầu chỉ có `README.md`, `AGENTS.md`, `CODEX_AUTOMATION_PROMPT.md`; vì vậy baseline RTL trong `rtl/` được tạo mới để có điểm bắt đầu cho simulation/lint. Các số liệu FPGA/timing/resource: **Needs verification**.

## Top module khả thi

- `MM_ultra`: top compute pipeline phù hợp để test trước vì chỉ dùng stream feature/weight/output đơn giản.
- `GEMM_TOP`: wrapper cấp cao hiện là placeholder AXI-Stream quanh `MM_ultra`; AXI4-Lite đầy đủ chưa có dependency/IP. `GEMM_TOP requires AXI integration test`.

## Cây module

```text
GEMM_TOP
└── MM_ultra
    ├── MM_in_buffer
    ├── MM_buffer
    ├── MM
    │   └── PE_array
    └── MM_out_buffer
        └── right_shifter

PE_line
└── PE x COLS

AdderS
```

## Danh sách module RTL

| Module | File | Vai trò |
|---|---|---|
| `GEMM_TOP` | `rtl/GEMM_TOP.v` | Wrapper stream cấp cao; AXI4-Lite TODO. |
| `MM_ultra` | `rtl/MM_ultra.v` | Pipeline compute chính. |
| `MM_in_buffer` | `rtl/MM_in_buffer.v` | Thu thập block feature/weight theo stream. |
| `MM_buffer` | `rtl/MM_buffer.v` | One-entry elastic buffer. |
| `MM` | `rtl/MM.v` | Wrapper nhân ma trận, đăng ký output. |
| `PE_array` | `rtl/PE_array.v` | Dot-product array baseline theo packed row-major. |
| `PE_line` | `rtl/PE_line.v` | Một hàng PE tích lũy theo nhiều cột. |
| `PE` | `rtl/PE.v` | Signed INT8 MAC có reset/clear. |
| `AdderS` | `rtl/AdderS.v` | Cộng vector signed packed. |
| `right_shifter` | `rtl/right_shifter.v` | Shift số học và saturate INT8. |
| `MM_out_buffer` | `rtl/MM_out_buffer.v` | Serialize kết quả và quantize. |

## Dependency còn thiếu

- AXI4-Lite register bank/control cho `GEMM_TOP`: **Needs verification/TODO**.
- AXI DMA/IP wrapper, Xilinx board design, block design `.bd`: **Needs verification/TODO**.
- Vivado chưa chạy trong môi trường hiện tại: **Needs verification**.
