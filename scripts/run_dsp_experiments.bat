@echo off
setlocal
set "VIVADO_BIN=D:\Vivado\2022.2\bin"
set "VIVADO_BAT=%VIVADO_BIN%\vivado.bat"

if not exist "%VIVADO_BAT%" (
  echo ERROR: Khong tim thay Vivado tai "%VIVADO_BAT%".
  echo        Hay kiem tra cai dat Vivado 2022.2 hoac cap nhat bien VIVADO_BIN trong scripts\run_dsp_experiments.bat.
  echo        DSP experiment synthesis: Needs verification.
  exit /b 2
)

if not exist reports\dsp_experiments mkdir reports\dsp_experiments
"%VIVADO_BAT%" -mode batch -source scripts\run_dsp_experiments.tcl
if errorlevel 1 exit /b %errorlevel%

python scripts\parse_dsp_experiments.py --write-doc
exit /b %errorlevel%
