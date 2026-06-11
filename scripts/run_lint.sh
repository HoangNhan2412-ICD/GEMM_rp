#!/usr/bin/env bash
set -euo pipefail
RTL=(rtl/PE.v rtl/AdderS.v rtl/right_shifter.v rtl/PE_line.v rtl/PE_array.v rtl/MM.v rtl/MM_in_buffer.v rtl/MM_buffer.v rtl/MM_out_buffer.v rtl/MM_ultra.v rtl/GEMM_TOP.v)
if command -v verilator >/dev/null 2>&1; then
  verilator --lint-only -Wall --timing "${RTL[@]}"
elif command -v iverilog >/dev/null 2>&1; then
  mkdir -p build
  iverilog -g2012 -Wall -tnull "${RTL[@]}"
else
  echo "WARNING: neither verilator nor iverilog found. Lint Needs verification."
  exit 2
fi
