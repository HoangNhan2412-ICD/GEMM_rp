@echo off
where vivado >nul 2>nul
if errorlevel 1 (
  echo WARNING: Vivado not found. KV260 synthesis/implementation Needs verification.
  echo Run on a Vivado machine: vivado -mode batch -source scripts/run_vivado_kv260.tcl
  exit /b 2
)
vivado -mode batch -source scripts/run_vivado_kv260.tcl || exit /b %errorlevel%
python scripts\parse_vivado_reports.py reports\kv260
