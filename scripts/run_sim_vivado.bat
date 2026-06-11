@echo off
setlocal enabledelayedexpansion
set "VIVADO_BIN=D:\Vivado\2022.2\bin"
set "XVLOG_BAT=%VIVADO_BIN%\xvlog.bat"
set "XELAB_BAT=%VIVADO_BIN%\xelab.bat"
set "XSIM_BAT=%VIVADO_BIN%\xsim.bat"

if not exist "%XVLOG_BAT%" (
  echo ERROR: Khong tim thay xvlog tai "%XVLOG_BAT%".
  echo        Vivado xsim compile: Needs verification.
  exit /b 2
)
if not exist "%XELAB_BAT%" (
  echo ERROR: Khong tim thay xelab tai "%XELAB_BAT%".
  echo        Vivado xsim elaboration: Needs verification.
  exit /b 2
)
if not exist "%XSIM_BAT%" (
  echo ERROR: Khong tim thay xsim tai "%XSIM_BAT%".
  echo        Vivado xsim run: Needs verification.
  exit /b 2
)

if not exist build mkdir build
if not exist build\xsim mkdir build\xsim

set "TB_TOPS="
for %%F in (tb\tb_*.v) do (
  set "TB_NAME=%%~nF"
  set "TB_TOPS=!TB_TOPS! !TB_NAME!"
)

if "!TB_TOPS!"=="" (
  echo ERROR: Khong tim thay top testbench nao theo mau tb\tb_*.v.
  echo        TODO: Bo sung testbench hoac cap nhat logic phat hien top trong scripts\run_sim_vivado.bat.
  exit /b 2
)

echo [XSIM] Testbench tops:!TB_TOPS!
pushd build\xsim
if not exist build mkdir build

echo [XSIM] Compile rtl\*.v and tb\*.v with xvlog
"%XVLOG_BAT%" -sv -i ..\..\tb ..\..\rtl\*.v ..\..\tb\*.v
if errorlevel 1 (
  popd
  exit /b !errorlevel!
)

for %%T in (!TB_TOPS!) do (
  echo [XSIM] Elaborate %%T
  "%XELAB_BAT%" %%T -snapshot %%T_snap -debug typical
  if errorlevel 1 (
    popd
    exit /b !errorlevel!
  )
  echo [XSIM] Run %%T
  "%XSIM_BAT%" %%T_snap -runall
  if errorlevel 1 (
    popd
    exit /b !errorlevel!
  )
)

popd
echo [XSIM] All discovered Vivado simulations completed.
exit /b 0
