# Known issues

1. Repo ban đầu không có RTL source; baseline hiện tại là scaffold chức năng, cần review kiến trúc với yêu cầu gốc.
2. `GEMM_TOP` chưa có AXI4-Lite register bank/control map hoàn chỉnh. **Needs verification/TODO**.
3. Chưa chạy HDL lint/simulation vì môi trường không có Verilator/Icarus. **Needs verification**.
4. Chưa chạy Vivado synthesis/implementation; không có số liệu LUT/FF/BRAM/DSP/timing/power. **Needs verification**.
5. `PE_array` hiện là dot-product combinational baseline, chưa mô hình hóa timing systolic wavefront đầy đủ.
6. `multi_block` và `reset_mid_transaction` chưa có coverage HDL đầy đủ.
7. Constraint I/O `LVCMOS33` trong XDC là placeholder và cần kiểm tra theo board design thật.
