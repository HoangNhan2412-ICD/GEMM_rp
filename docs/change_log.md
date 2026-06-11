# Change log

## codex/research-grade-automation

- Tạo baseline RTL synthesizable cho pipeline GEMM INT8: `PE`, `PE_line`, `PE_array`, `AdderS`, `right_shifter`, `MM`, `MM_in_buffer`, `MM_buffer`, `MM_out_buffer`, `MM_ultra`, `GEMM_TOP`.
- Tạo testbench baseline có PASS/FAIL và VCD dump cho các unit/integration quan trọng.
- Tạo script lint/simulation/regression và flow Vivado KV260.
- Tạo tài liệu kiến trúc, protocol, dataflow, FSM, testcase, report template và draft nghiên cứu tiếng Việt.

Chưa thay đổi interface top-level từ IP có sẵn vì repo ban đầu không có RTL/IP cũ.

## Windows Vivado 2022.2 automation update

- Cập nhật `scripts/run_synth_kv260.bat` để gọi trực tiếp `D:\Vivado\2022.2\bin\vivado.bat` và báo lỗi rõ ràng nếu không tìm thấy.
- Thêm `scripts/run_sim_vivado.bat` dùng `xvlog.bat`, `xelab.bat`, `xsim.bat`, compile `rtl\*.v` và `tb\*.v`, tự phát hiện top testbench theo `tb\tb_*.v`.
- Thêm `docs/toolchain_setup.md` hướng dẫn kiểm tra Vivado, chạy synthesis KV260 và chạy Vivado xsim trên Windows.

Kết quả synthesis/simulation Vivado vẫn **Needs verification** trong môi trường agent nếu không có Vivado/report thật.

## Ghi nhận kết quả Vivado thật từ máy Windows

- Người dùng xác nhận đã chạy Vivado synthesis/implementation thật và parse report trong `reports/kv260/`.
- Cập nhật `docs/resource_report.md`, `docs/timing_report.md`, `docs/synthesis_report.md` để phân biệt số liệu Vivado thật do người dùng báo cáo với phần agent chưa thể audit do thiếu file `.rpt` trong checkout.
- Ghi nhận số liệu đã báo cáo: LUT = 4706, FF = 1119, BRAM = 0, DSP = 0, DRC report present = true.
- Tạo `docs/dsp_inference_plan.md` để điều tra `DSP = 0` mà chưa sửa RTL/kiến trúc lớn.

## Ghi nhận timing post-implementation thật 100 MHz

- Cập nhật `docs/timing_report.md` với timing thật từ `reports/kv260/post_impl_timing_summary.rpt`: clock `clk`, period `10.000 ns`, 100 MHz, WNS = 4.021 ns, TNS = 0.000 ns, setup failing endpoints = 0, WHS = 0.030 ns, THS = 0.000 ns, hold failing endpoints = 0.
- Cập nhật `docs/synthesis_report.md` để ghi rõ baseline implementation của top `GEMM_TOP` đạt timing 100 MHz và Vivado báo `All user specified timing constraints are met.`.
- Cập nhật `docs/resource_report.md` để ghi rõ resource đã verified: LUT = 4706, FF = 1119, BRAM = 0, DSP = 0; `DSP = 0` verified ở cả post-synthesis và post-implementation utilization.
- Cập nhật `docs/dsp_inference_plan.md` để nhấn mạnh `DSP = 0` là verified nhưng nguyên nhân chưa kết luận.
- Không sửa RTL và không công bố power vì chưa đọc/ghi nhận giá trị từ `post_impl_power.rpt` thật trong task này.

## Merge conflict resolution audit

- Đã kiểm tra và không còn marker conflict kiểu Git trong tree làm việc.
- Giữ nguyên kết quả Vivado KV260 đã verified: LUT = 4706, FF = 1119, BRAM = 0, DSP = 0, WNS = 4.021 ns, TNS = 0.000 ns, WHS = 0.030 ns, THS = 0.000 ns, setup failing endpoints = 0, hold failing endpoints = 0, timing status `All user specified timing constraints are met.`.
- Giữ `docs/dsp_inference_plan.md` và ghi rõ `DSP = 0` đã verified nhưng nguyên nhân vẫn cần kiểm chứng bằng hierarchy/netlist/schematic/cell primitive.
- Giữ `scripts/parse_vivado_reports.py` với khả năng parse LUT/FF/BRAM/DSP, WNS/TNS/WHS/THS, setup/hold failing endpoints và trạng thái timing constraints met.
- Giữ `scripts/run_synth_kv260.bat` dùng Vivado Windows tại `D:\Vivado\2022.2\bin\vivado.bat`, có thông báo lỗi rõ ràng nếu thiếu Vivado và vẫn chạy `scripts\run_vivado_kv260.tcl`.
- Không sửa RTL trong bước resolve conflict này.
