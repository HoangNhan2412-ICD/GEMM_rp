#!/usr/bin/env bash
set -euo pipefail
if ! command -v vivado >/dev/null 2>&1; then
  echo "WARNING: Vivado not found. DSP experiment synthesis Needs verification."
  echo "Run on a Vivado machine: vivado -mode batch -source scripts/run_dsp_experiments.tcl"
  exit 2
fi
vivado -mode batch -source scripts/run_dsp_experiments.tcl
python3 scripts/parse_dsp_experiments.py --write-doc
