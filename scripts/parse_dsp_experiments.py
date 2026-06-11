#!/usr/bin/env python3
"""Aggregate Vivado DSP experiment reports across multiple synthesis tops.

This script parses reports/dsp_experiments/<top>/ using parse_vivado_reports.py
and writes reports/dsp_experiments/summary.json. With --write-doc it also
updates docs/dsp_experiment_report.md. It does not invent missing metrics.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

from parse_vivado_reports import parse  # noqa: E402

TOPS = ["PE", "PE_array", "MM", "MM_ultra", "GEMM_TOP"]
METRICS = ["LUT", "FF", "BRAM", "DSP", "WNS", "TNS"]


def read_text(path: Path) -> str:
    return path.read_text(errors="ignore") if path.exists() else ""


def parse_dsp_probe(path: Path) -> dict[str, int]:
    text = read_text(path)
    data: dict[str, int] = {}
    for key, label in {
        "dsp_primitive_cells": "DSP primitive cells",
        "multiplier_named_cells": "Multiplier/product-named cells",
    }.items():
        m = re.search(rf"{re.escape(label)}:\s*([0-9]+)", text, re.I)
        if m:
            data[key] = int(m.group(1))
    return data


def summarize_top(report_root: Path, top: str) -> dict[str, Any]:
    report_dir = report_root / top
    summary: dict[str, Any] = {
        "top": top,
        "report_dir": str(report_dir),
        "present": report_dir.exists(),
    }
    if report_dir.exists():
        parsed = parse(report_dir)
        for metric in METRICS:
            if metric in parsed:
                summary[metric] = parsed[metric]
        timing = parsed.get("reports", {}).get("post_synth_timing_summary", {})
        if "constraints_met" in timing:
            summary["constraints_met"] = timing["constraints_met"]
        summary.update(parse_dsp_probe(report_dir / "dsp_cell_probe.rpt"))
    return summary


def aggregate(report_root: Path) -> dict[str, Any]:
    return {
        "report_root": str(report_root),
        "tops": [summarize_top(report_root, top) for top in TOPS],
    }


def md_value(row: dict[str, Any], metric: str) -> str:
    value = row.get(metric)
    return f"`{value}`" if value is not None else "Needs verification"


def infer_focus(top: str) -> str:
    return {
        "PE": "Kiểm tra MAC registered INT8 đơn lẻ (`feature_i * weight_i` cộng accumulator).",
        "PE_array": "Kiểm tra dot-product combinational có nhiều multiplier INT8 trong compute core baseline.",
        "MM": "Kiểm tra wrapper registered quanh `PE_array`; xác định multiplier có còn trong cone `MM` không.",
        "MM_ultra": "Kiểm tra pipeline input/buffer/MM/output; xác định compute path có bị optimize qua stream control không.",
        "GEMM_TOP": "So sánh với baseline top wrapper đã verified DSP = 0.",
    }[top]


def write_doc(summary: dict[str, Any], doc_path: Path) -> None:
    lines: list[str] = []
    lines.append("# DSP experiment report")
    lines.append("")
    lines.append("## Mục tiêu")
    lines.append("")
    lines.append("Flow này synthesize riêng các top `PE`, `PE_array`, `MM`, `MM_ultra`, `GEMM_TOP` để điều tra vì sao baseline `GEMM_TOP` verified `DSP = 0` trên KV260/K26. RTL chính không bị sửa và flow này không dùng `(* use_dsp = \"yes\" *)`.")
    lines.append("")
 codex/create-research-grade-automation-project-5wi553
    lines.append("Kế hoạch chi tiết, giả thuyết cần kiểm chứng và quy tắc về `use_dsp` được ghi trong `docs/dsp_experiment_plan.md`.")
    lines.append("")

 main
    lines.append("## Cách chạy")
    lines.append("")
    lines.append("Linux/Vivado trong PATH:")
    lines.append("")
    lines.append("```bash")
    lines.append("scripts/run_dsp_experiments.sh")
    lines.append("```")
    lines.append("")
    lines.append("Windows Vivado 2022.2:")
    lines.append("")
    lines.append("```bat")
    lines.append("scripts\\run_dsp_experiments.bat")
    lines.append("```")
    lines.append("")
    lines.append("Report từng top được ghi vào `reports/dsp_experiments/<top_name>/`. Sau khi có report thật, chạy lại parser nếu cần:")
    lines.append("")
    lines.append("```bash")
    lines.append("python3 scripts/parse_dsp_experiments.py --write-doc")
    lines.append("```")
    lines.append("")
    lines.append("## Bảng so sánh")
    lines.append("")
    lines.append("| Top | LUT | FF | BRAM | DSP | WNS | TNS | DSP primitive cells | Mult/product named cells | Trọng tâm kiểm tra |")
    lines.append("|---|---:|---:|---:|---:|---:|---:|---:|---:|---|")
    for row in summary["tops"]:
        top = row["top"]
        lines.append(
            "| "
            + " | ".join(
                [
                    f"`{top}`",
                    md_value(row, "LUT"),
                    md_value(row, "FF"),
                    md_value(row, "BRAM"),
                    md_value(row, "DSP"),
                    md_value(row, "WNS"),
                    md_value(row, "TNS"),
                    md_value(row, "dsp_primitive_cells"),
                    md_value(row, "multiplier_named_cells"),
                    infer_focus(top),
                ]
            )
            + " |"
        )
    lines.append("")
    lines.append("## Baseline verified để đối chiếu")
    lines.append("")
    lines.append("Baseline `GEMM_TOP` implementation đã verified trước đó trên KV260/K26: LUT = 4706, FF = 1119, BRAM = 0, DSP = 0, WNS = 4.021 ns, TNS = 0.000 ns, WHS = 0.030 ns, THS = 0.000 ns, setup failing endpoints = 0, hold failing endpoints = 0, timing status `All user specified timing constraints are met.`")
    lines.append("")
    lines.append("## Diễn giải dự kiến")
    lines.append("")
    lines.append("- Nếu `PE` có DSP > 0 nhưng `PE_array`/`MM`/`GEMM_TOP` vẫn DSP = 0, khả năng compute path hiện tại không đi qua MAC registered `PE` trong top baseline.")
    lines.append("- Nếu `PE_array` và `MM` đều DSP = 0 trong khi vẫn có multiplier/product-named cells, khả năng Vivado map multiplier INT8 nhỏ sang LUT hoặc coding style combinational chưa infer DSP48.")
    lines.append("- Nếu multiplier/product-named cells biến mất ở `MM_ultra` hoặc `GEMM_TOP`, cần kiểm tra stream/control và visibility để xem compute path có bị optimize không.")
    lines.append("- Không kết luận nguyên nhân cuối cùng nếu chưa có report thật trong `reports/dsp_experiments/`; ghi `Needs verification` cho kết quả chưa chạy.")
    lines.append("")
    lines.append("## Trạng thái")
    lines.append("")
    if any(row.get("present") for row in summary["tops"]):
        lines.append("Đã parse các report hiện có trong `reports/dsp_experiments/`. Các ô còn `Needs verification` là metric chưa tìm thấy trong report thật.")
    else:
        lines.append("Chưa có report Vivado thật trong `reports/dsp_experiments/` tại thời điểm tạo tài liệu này. Cần chạy flow trên máy có Vivado. **Needs verification**.")
    doc_path.write_text("\n".join(lines) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--report-root", default="reports/dsp_experiments", type=Path)
    parser.add_argument("--write-doc", action="store_true", help="Update docs/dsp_experiment_report.md")
    parser.add_argument("--doc", default=Path("docs/dsp_experiment_report.md"), type=Path)
    args = parser.parse_args()

    summary = aggregate(args.report_root)
    args.report_root.mkdir(parents=True, exist_ok=True)
    out = args.report_root / "summary.json"
    out.write_text(json.dumps(summary, indent=2, ensure_ascii=False) + "\n")
    print(json.dumps(summary, indent=2, ensure_ascii=False))

    if args.write_doc:
        args.doc.parent.mkdir(parents=True, exist_ok=True)
        write_doc(summary, args.doc)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
