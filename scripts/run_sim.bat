@echo off
if not exist build mkdir build
where iverilog >nul 2>nul
if errorlevel 1 (
  echo WARNING: iverilog not found. Simulation Needs verification.
  exit /b 2
)
set RTL=rtl\PE.v rtl\AdderS.v rtl\right_shifter.v rtl\PE_line.v rtl\PE_array.v rtl\MM.v rtl\MM_in_buffer.v rtl\MM_buffer.v rtl\MM_out_buffer.v rtl\MM_ultra.v rtl\GEMM_TOP.v
for %%T in (tb_PE tb_PE_line tb_PE_array tb_right_shifter tb_AdderS tb_MM_ultra) do (
  echo [SIM] %%T
  iverilog -g2012 -I tb -o build\%%T.vvp tb\%%T.v %RTL%
  vvp build\%%T.vvp || exit /b 1
)
