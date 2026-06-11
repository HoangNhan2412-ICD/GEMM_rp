#!/usr/bin/env python3
"""Best-effort parser for Vivado reports. Prints only values found in real files."""
from __future__ import annotations
import json, re, sys
from pathlib import Path

def read(path: Path) -> str:
    return path.read_text(errors="ignore") if path.exists() else ""

def find_table_value(text: str, names):
    for name in names:
        m = re.search(rf"\|\s*{re.escape(name)}\s*\|\s*([0-9.]+)", text, re.I)
        if m:
            return m.group(1)
    return None

def parse(report_dir: Path):
    util = read(report_dir / "post_impl_utilization.rpt") or read(report_dir / "post_synth_utilization.rpt")
    timing = read(report_dir / "post_impl_timing_summary.rpt") or read(report_dir / "post_synth_timing_summary.rpt")
    drc = read(report_dir / "post_impl_drc.rpt")
    power = read(report_dir / "post_impl_power.rpt")
    data = {}
    if util:
        data["LUT"] = find_table_value(util, ["CLB LUTs", "Slice LUTs", "LUT as Logic"])
        data["FF"] = find_table_value(util, ["CLB Registers", "Slice Registers", "Register as Flip Flop"])
        data["BRAM"] = find_table_value(util, ["Block RAM Tile", "RAMB36/FIFO", "RAMB18"])
        data["DSP"] = find_table_value(util, ["DSPs", "DSP48E2", "DSP"])
    if timing:
        for key in ["WNS", "TNS"]:
            m = re.search(rf"{key}\(ns\)\s*[:=]?\s*(-?[0-9.]+)", timing)
            if not m:
                m = re.search(rf"\b{key}\b\s+(-?[0-9.]+)", timing)
            if m:
                data[key] = m.group(1)
        m = re.search(r"Failing Endpoints\s*[:=]?\s*([0-9]+)", timing, re.I)
        if m:
            data["Failing endpoints"] = m.group(1)
    if drc:
        data["DRC report present"] = True
    if power:
        data["Power report present"] = True
    return {k: v for k, v in data.items() if v is not None}

if __name__ == "__main__":
    report_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("reports/kv260")
    if not report_dir.exists():
        print(f"No report directory found: {report_dir}. Needs verification.")
        sys.exit(2)
    result = parse(report_dir)
    out = report_dir / "parsed_summary.json"
    out.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n")
    if result:
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print("No parseable Vivado metrics found. Needs verification.")
