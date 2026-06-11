@echo off
setlocal
set "VIVADO_BIN=D:\Vivado\2022.2\bin"
set "VIVADO_BAT=%VIVADO_BIN%\vivado.bat"

if not exist "%VIVADO_BAT%" (
  echo ERROR: Khong tim thay Vivado tai "%VIVADO_BAT%".
  echo        Hay kiem tra cai dat Vivado 2022.2 hoac cap nhat bien VIVADO_BIN trong scripts\run_synth_kv260.bat.
  echo        Synthesis/implementation KV260: Needs verification.
  exit /b 2
)

if not exist reports\kv260 mkdir reports\kv260
"%VIVADO_BAT%" -mode batch -source scripts\run_vivado_kv260.tcl
if errorlevel 1 exit /b %errorlevel%

python scripts\parse_vivado_reports.py reports\kv260
exit /b %errorlevel%
