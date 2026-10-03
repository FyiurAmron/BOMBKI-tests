#!/usr/bin/env python3
"""Compare TP7-rebuilt units byte-for-byte with the retained originals."""

import argparse
import sys
from pathlib import Path

UNITS = ("MONSTRA.TPU", "PRZEDM.TPU", "SWIAT.TPU")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--original-dir", type=Path, required=True)
    parser.add_argument("--rebuilt-dir", type=Path, required=True)
    args = parser.parse_args()

    failures = 0
    for name in UNITS:
        original_path = args.original_dir / name
        rebuilt_path = args.rebuilt_dir / name
        if not original_path.is_file():
            print(f"FAIL {name}: original missing: {original_path}")
            failures += 1
            continue
        if not rebuilt_path.is_file():
            print(f"FAIL {name}: rebuilt TPU missing: {rebuilt_path}")
            failures += 1
            continue

        original = original_path.read_bytes()
        rebuilt = rebuilt_path.read_bytes()
        if original[:4] != b"TPUQ" or rebuilt[:4] != b"TPUQ":
            print(
                f"FAIL {name}: invalid TPUQ signature "
                f"(original={original[:4]!r}, rebuilt={rebuilt[:4]!r})"
            )
            failures += 1
            continue
        if original == rebuilt:
            print(f"PASS {name}: byte-identical ({len(original)} bytes)")
            continue

        failures += 1
        first = next(
            (offset for offset, (a, b) in enumerate(zip(original, rebuilt))
             if a != b),
            min(len(original), len(rebuilt)),
        )
        print(
            f"FAIL {name}: original={len(original)} bytes, "
            f"rebuilt={len(rebuilt)} bytes, "
            f"first difference at 0x{first:04X}"
        )
        print(
            f"::error title=TPU byte mismatch::{name}: sizes "
            f"{len(original)}->{len(rebuilt)}, "
            f"first difference at 0x{first:04X}"
        )

    if failures:
        print(f"TPU byte comparison failed: {failures} unit(s) differ or are missing")
        return 1
    print("All reconstructed TPUs are byte-identical to the retained originals")
    return 0


if __name__ == "__main__":
    sys.exit(main())
