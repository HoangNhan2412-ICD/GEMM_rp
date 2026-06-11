#!/usr/bin/env python3
"""Best-effort parser for Vivado KV260 reports.

The script prints only values found in real report files. It never invents
resource/timing/power numbers when a report or table entry is missing.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any

REPORTS = {
    "post_synth_utilization": "post_synth_utilization.rpt",
    "post_synth_timing_summary": "post_synth_timing_summary.rpt",
    "post_impl_utilization": "post_impl_utilization.rpt",
    "post_impl_timing_summary": "post_impl_timing_summary.rpt",
    "post_impl_power": "post_impl_power.rpt",
    "post_impl_drc": "post_impl_drc.rpt",
}


def read(path: Path) -> str:
    return path.read_text(errors="ignore") if path.exists() else ""


def find_table_value(text: str, names: list[str]) -> str | None:
    for name in names:
        # Vivado tables commonly use: | CLB LUTs | 4706 | ... |
        m = re.search(rf"\|\s*{re.escape(name)}\s*\|\s*([0-9.]+)", text, re.I)
        if m:
            return m.group(1)
    return None


def parse_utilization(text: str) -> dict[str, str]:
    data: dict[str, str] = {}
    mapping = {
        "LUT": ["CLB LUTs", "Slice LUTs", "LUT as Logic"],
        "FF": ["CLB Registers", "Slice Registers", "Register as Flip Flop"],
        "BRAM": ["Block RAM Tile", "RAMB36/FIFO", "RAMB18"],
        "DSP": ["DSPs", "DSP48E2", "DSP"],
    }
    for key, names in mapping.items():
        value = find_table_value(text, names)
        if value is not None:
            data[key] = value
    return data


def normalize_timing_label(label: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", label.strip().lower()).strip("_")


def parse_vivado_pipe_tables(text: str) -> list[dict[str, str]]:
    rows: list[list[str]] = []
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped.startswith("|") or not stripped.endswith("|"):
            continue
        cells = [cell.strip() for cell in stripped.strip("|").split("|")]
        if not cells or all(re.fullmatch(r"[-: ]*", cell) for cell in cells):
            continue
        rows.append(cells)

    tables: list[dict[str, str]] = []
    for idx, cells in enumerate(rows[:-1]):
        value_cells = rows[idx + 1]
        if len(cells) != len(value_cells):
            continue
        if not any(re.search(r"\b(WNS|TNS|WHS|THS|WPWS|TPWS)\b", cell, re.I) for cell in cells):
            continue
        if not any(re.fullmatch(r"-?[0-9.]+", cell) for cell in value_cells):
            continue
        tables.append({normalize_timing_label(k): v for k, v in zip(cells, value_cells)})
    return tables


def parse_timing(text: str) -> dict[str, str | bool]:
    data: dict[str, str | bool] = {}

    # Vivado timing summary commonly appears as a pipe table with headers such as
    # WNS(ns), TNS(ns), TNS Failing Endpoints, WHS(ns), THS(ns), ...
    for table in parse_vivado_pipe_tables(text):
        table_mapping = {
            "WNS": ["wns_ns", "wns"],
            "TNS": ["tns_ns", "tns"],
            "WHS": ["whs_ns", "whs"],
            "THS": ["ths_ns", "ths"],
            "WPWS": ["wpws_ns", "wpws"],
            "TPWS": ["tpws_ns", "tpws"],
            "setup_failing_endpoints": ["tns_failing_endpoints", "setup_failing_endpoints"],
            "setup_total_endpoints": ["tns_total_endpoints", "setup_total_endpoints"],
            "hold_failing_endpoints": ["ths_failing_endpoints", "hold_failing_endpoints"],
            "hold_total_endpoints": ["ths_total_endpoints", "hold_total_endpoints"],
            "pulse_width_failing_endpoints": ["tpws_failing_endpoints"],
            "pulse_width_total_endpoints": ["tpws_total_endpoints"],
        }
        for out_key, labels in table_mapping.items():
            for label in labels:
                if label in table and out_key not in data:
                    data[out_key] = table[label]
                    break

    # Fallback regex for non-table snippets or custom report excerpts.
    for key in ["WNS", "TNS", "WHS", "THS", "WPWS", "TPWS"]:
        if key in data:
            continue
        patterns = [
            rf"{key}\(ns\)\s*[:=]?\s*(-?[0-9.]+)",
            rf"\b{key}\b\s*[:=]\s*(-?[0-9.]+)",
            rf"\b{key}\b\s+(-?[0-9.]+)",
        ]
        for pattern in patterns:
            m = re.search(pattern, text)
            if m:
                data[key] = m.group(1)
                break

    endpoint_patterns = {
        "setup_failing_endpoints": [
            r"Setup\s+Failing\s+Endpoints\s*[:=]?\s*([0-9]+)",
            r"TNS\s+Failing\s+Endpoints\s*[:=]?\s*([0-9]+)",
        ],
        "hold_failing_endpoints": [
            r"Hold\s+Failing\s+Endpoints\s*[:=]?\s*([0-9]+)",
            r"THS\s+Failing\s+Endpoints\s*[:=]?\s*([0-9]+)",
        ],
        "failing_endpoints": [r"Failing\s+Endpoints\s*[:=]?\s*([0-9]+)"],
        "total_endpoints": [r"Total\s+Endpoints\s*[:=]?\s*([0-9]+)"],
    }
    for out_key, patterns in endpoint_patterns.items():
        if out_key in data:
            continue
        for pattern in patterns:
            m = re.search(pattern, text, re.I)
            if m:
                data[out_key] = m.group(1)
                break

    if re.search(r"All user specified timing constraints are met", text, re.I):
        data["constraints_met"] = True
    return data


def parse_power(text: str) -> dict[str, str | bool]:
    data: dict[str, str | bool] = {"report_present": True}
    # Common Vivado line/table labels. Keep best-effort and omit if absent.
    for out_key, labels in {
        "total_on_chip_power_w": ["Total On-Chip Power", "Total On-Chip Power (W)"],
        "dynamic_power_w": ["Dynamic", "Dynamic (W)"],
        "static_power_w": ["Device Static", "Static Power", "Static (W)"],
    }.items():
        for label in labels:
            m = re.search(rf"{re.escape(label)}\s*\|?\s*([0-9.]+)\s*W?", text, re.I)
            if m:
                data[out_key] = m.group(1)
                break
    return data


def parse_drc(text: str) -> dict[str, Any]:
    data: dict[str, Any] = {"report_present": True}
    # Vivado DRC formats vary; capture obvious violation counts when present.
    m = re.search(r"Violations\s*:\s*([0-9]+)", text, re.I)
    if m:
        data["violations"] = int(m.group(1))
    severities: dict[str, int] = {}
    for severity in ["Critical Warning", "Error", "Warning", "Info"]:
        m = re.search(rf"{severity}s?\s*[:=]\s*([0-9]+)", text, re.I)
        if m:
            severities[severity.lower().replace(" ", "_")] = int(m.group(1))
    if severities:
        data["severities"] = severities
    return data


def parse(report_dir: Path) -> dict[str, Any]:
    result: dict[str, Any] = {"report_dir": str(report_dir), "reports": {}}
    reports: dict[str, Any] = result["reports"]

    for report_key, filename in REPORTS.items():
        path = report_dir / filename
        text = read(path)
        reports[report_key] = {"file": filename, "present": bool(text)}
        if not text:
            continue
        if "utilization" in report_key:
            reports[report_key].update(parse_utilization(text))
        elif "timing" in report_key:
            reports[report_key].update(parse_timing(text))
        elif report_key == "post_impl_power":
            reports[report_key].update(parse_power(text))
        elif report_key == "post_impl_drc":
            reports[report_key].update(parse_drc(text))

    # Backward-compatible top-level summary prefers post-implementation metrics.
    for key in ["LUT", "FF", "BRAM", "DSP"]:
        value = reports["post_impl_utilization"].get(key) or reports["post_synth_utilization"].get(key)
        if value is not None:
            result[key] = value
    for key in [
        "WNS",
        "TNS",
        "WHS",
        "THS",
        "setup_failing_endpoints",
        "hold_failing_endpoints",
        "failing_endpoints",
        "constraints_met",
    ]:
        value = reports["post_impl_timing_summary"].get(key) or reports["post_synth_timing_summary"].get(key)
        if value is not None:
            result[key] = value
    if reports["post_impl_power"].get("present"):
        result["Power report present"] = True
    if reports["post_impl_drc"].get("present"):
        result["DRC report present"] = True

    return result


if __name__ == "__main__":
    report_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("reports/kv260")
    if not report_dir.exists():
        print(f"No report directory found: {report_dir}. Needs verification.")
        sys.exit(2)
    parsed = parse(report_dir)
    out = report_dir / "parsed_summary.json"
    out.write_text(json.dumps(parsed, indent=2, ensure_ascii=False) + "\n")
    print(json.dumps(parsed, indent=2, ensure_ascii=False))
