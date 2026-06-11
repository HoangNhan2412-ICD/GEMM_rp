@echo off
setlocal

set "VIVADO_BIN=D:\Vivado\2022.2\bin"
set "VIVADO=%VIVADO_BIN%\vivado.bat"

if not exist "%VIVADO%" (
    echo ERROR: Cannot find Vivado at "%VIVADO%"
    echo Please check your Vivado path.
    exit /b 1
)

echo Using Vivado: %VIVADO%
"%VIVADO%" -mode batch -source "%CD%\scripts\run_vivado_kv260.tcl"

endlocal
