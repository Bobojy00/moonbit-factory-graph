#!/usr/bin/env python3
"""Count production MoonBit source lines and optionally enforce a floor."""

from __future__ import annotations

import argparse
from pathlib import Path


EXCLUDED_DIRS = {".git", ".repos", "_build", "target"}


def production_files(root: Path) -> list[Path]:
    files: list[Path] = []
    for path in root.rglob("*.mbt"):
        relative = path.relative_to(root)
        if any(part in EXCLUDED_DIRS for part in relative.parts):
            continue
        if path.name.endswith("_test.mbt") or path.name.endswith("_wbtest.mbt"):
            continue
        files.append(path)
    return sorted(files)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--minimum", type=int, default=0)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    files = production_files(root)
    lines = sum(path.read_text(encoding="utf-8").count("\n") for path in files)
    print(f"production_files={len(files)}")
    print(f"production_lines={lines}")
    if lines < args.minimum:
        print(f"error: production source is below the required floor ({args.minimum})")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
