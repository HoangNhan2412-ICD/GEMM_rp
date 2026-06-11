#!/usr/bin/env bash
set -euo pipefail
mkdir -p build
if ! command -v iverilog >/dev/null 2>&1 || ! command -v vvp >/dev/null 2>&1; then
  echo "WARNING: iverilog/vvp not found. Simulation Needs verification."
  exit 2
fi
RTL=(rtl/PE.v rtl/AdderS.v rtl/right_shifter.v rtl/PE_line.v rtl/PE_array.v rtl/MM.v rtl/MM_in_buffer.v rtl/MM_buffer.v rtl/MM_out_buffer.v rtl/MM_ultra.v rtl/GEMM_TOP.v)
TESTS=(tb_PE tb_PE_line tb_PE_array tb_right_shifter tb_AdderS tb_MM_ultra)
for tb in "${TESTS[@]}"; do
  echo "[SIM] $tb"
  iverilog -g2012 -I tb -o "build/${tb}.vvp" "tb/${tb}.v" "${RTL[@]}"
  vvp "build/${tb}.vvp"
done
