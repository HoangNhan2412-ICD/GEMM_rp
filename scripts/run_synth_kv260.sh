#!/usr/bin/env bash
set -euo pipefail
if ! command -v vivado >/dev/null 2>&1; then
  echo "WARNING: Vivado not found. KV260 synthesis/implementation Needs verification."
  echo "Run on a Vivado machine: vivado -mode batch -source scripts/run_vivado_kv260.tcl"
  exit 2
fi
vivado -mode batch -source scripts/run_vivado_kv260.tcl
python3 scripts/parse_vivado_reports.py reports/kv260
