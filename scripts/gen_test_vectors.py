#!/usr/bin/env python3
"""Generate deterministic 2x2 INT8 GEMM vectors for documentation/test extension."""
from __future__ import annotations
import json, random
from pathlib import Path

def matmul(a, b):
    return [[sum(a[r][k] * b[k][c] for k in range(len(b))) for c in range(len(b[0]))] for r in range(len(a))]

def main():
    random.seed(12345)
    cases = {
        "zero_matrix": ([[0,0],[0,0]], [[0,0],[0,0]]),
        "identity_matrix": ([[1,2],[3,4]], [[1,0],[0,1]]),
        "positive_small": ([[1,2],[3,4]], [[5,6],[7,8]]),
        "signed_negative": ([[-1,-2],[-3,-4]], [[1,2],[3,4]]),
        "mixed_sign": ([[1,2],[3,4]], [[-1,2],[3,-4]]),
        "max_min_int8": ([[127,-128],[127,-128]], [[127,-128],[-128,127]]),
        "random_fixed_seed": ([[random.randint(-8,8) for _ in range(2)] for _ in range(2)], [[random.randint(-8,8) for _ in range(2)] for _ in range(2)]),
    }
    out = []
    for name, (a, b) in cases.items():
        out.append({"name": name, "A": a, "B": b, "C": matmul(a, b)})
    Path("build").mkdir(exist_ok=True)
    Path("build/test_vectors_2x2.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("Wrote build/test_vectors_2x2.json")

if __name__ == "__main__":
    main()
