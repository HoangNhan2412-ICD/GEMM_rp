@echo off
set RTL=rtl\PE.v rtl\AdderS.v rtl\right_shifter.v rtl\PE_line.v rtl\PE_array.v rtl\MM.v rtl\MM_in_buffer.v rtl\MM_buffer.v rtl\MM_out_buffer.v rtl\MM_ultra.v rtl\GEMM_TOP.v
where verilator >nul 2>nul
if not errorlevel 1 (
  verilator --lint-only -Wall --timing %RTL%
  exit /b %errorlevel%
)
where iverilog >nul 2>nul
if not errorlevel 1 (
  iverilog -g2012 -Wall -tnull %RTL%
  exit /b %errorlevel%
)
echo WARNING: neither verilator nor iverilog found. Lint Needs verification.
exit /b 2
