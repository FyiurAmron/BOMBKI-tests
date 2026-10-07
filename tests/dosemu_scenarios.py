#!/usr/bin/env python3
"""Original-versus-TP7 runtime smoke checks under DOSEMU2.

Every scenario in tests/scenarios runs against both the retained
original game (_reference) and the genuine TP7 rebuild (build/tp7),
under DOSEMU2's terminal frontend, driven through the
expect_pty.py PTY harness with pyte screen matching. A check
passes when the binary satisfies every step of the scenario.
The game seeds Random from the clock at startup, so the room
population text varies from run to run; the scenarios already
match it loosely, so no transcript equality is asserted here.
Host-native FPC results are not DOS behavior evidence; this
script is the final-check gate to run before pushing or in CI.
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
import time
from pathlib import Path

PROJECT = Path(__file__).resolve().parents[1]
SCENARIO_DIR = PROJECT / "tests" / "scenarios"
HARNESS = PROJECT / "tests" / "expect_pty.py"
WRAPPER = PROJECT / "tests" / "dosemu_game.sh"
REFERENCE_DIR = PROJECT / "_reference"
TP7_DIR = PROJECT / "build" / "tp7"
DOSEMU_ROOT = PROJECT / "build" / "dosemu"

# The original ships PLIKI.TPU (its save file). The TP7 build
# directory has no save file, so the reference copy stands in to
# give both variants identical starting conditions.
GAME_FILES = ("BOMBKI.EXE", "MONSTRA.TPU", "PRZEDM.TPU", "SWIAT.TPU",
              "PLIKI.TPU")

STEP_TIMEOUT = 60.0


def prepare_game_dir(variant: str) -> Path:
    """Stage a fresh copy of the game files for one DOSEMU2 run."""
    game_dir = DOSEMU_ROOT / "games" / variant
    if game_dir.exists():
        shutil.rmtree(game_dir)
    game_dir.mkdir(parents=True)
    for name in GAME_FILES:
        if variant == "tp7" and name != "PLIKI.TPU":
            source = TP7_DIR / name
        else:
            source = REFERENCE_DIR / name
        shutil.copy2(source, game_dir / name)
    return game_dir


def run_scenario(variant: str, scenario_path: Path,
                 step_timeout: float) -> Path:
    """Run one scenario against one variant under DOSEMU2.

    Returns the transcript log path; raises RuntimeError when the
    binary does not satisfy the scenario.
    """
    game_dir = prepare_game_dir(variant)
    scenario = json.loads(scenario_path.read_text(encoding="utf-8"))
    # The terminal frontend emits UTF-8 (external_char_set) and the
    # DOS CRT ReadLn wants CR as the Enter key.
    scenario["args"] = [str(game_dir)]
    scenario["encoding"] = "utf-8"
    scenario["line_ending"] = "\r"
    augmented_dir = DOSEMU_ROOT / "augmented"
    augmented_dir.mkdir(parents=True, exist_ok=True)
    augmented = augmented_dir / f"{variant}-{scenario_path.stem}.json"
    augmented.write_text(
        json.dumps(scenario, ensure_ascii=False, indent=2),
        encoding="utf-8")
    log = DOSEMU_ROOT / "logs" / f"{variant}-{scenario_path.stem}.jsonl"
    log.parent.mkdir(parents=True, exist_ok=True)
    steps = len(scenario["steps"])
    command = [sys.executable, str(HARNESS), str(WRAPPER), str(augmented),
               "--log", str(log), "--timeout", str(step_timeout),
               "--pyte"]
    try:
        result = subprocess.run(
            command, capture_output=True, text=True,
            timeout=(steps + 2) * step_timeout + 30)
    except subprocess.TimeoutExpired as error:
        raise RuntimeError(
            f"exceeded its time bound; DOSEMU2 processes may have "
            f"leaked") from error
    if result.returncode != 0:
        tail = (result.stdout or "")[-1500:]
        raise RuntimeError(
            f"scenario not satisfied (exit {result.returncode}); "
            f"transcript: {log}; output tail: {tail}")
    return log


def reap_dosemu() -> int:
    """Close DOSEMU2 instances left behind by this session's runs.
    Only processes whose command line references this project are
    touched; unrelated pre-existing instances are left alone."""
    reaped = 0
    try:
        listing = subprocess.run(["pgrep", "-af", "dosemu"],
                                 capture_output=True, text=True).stdout
    except OSError:
        return 0
    for line in listing.splitlines():
        if str(PROJECT) not in line:
            continue
        pid = line.split()[0]
        print(f"  reaping leftover DOSEMU2 process {pid}: "
              f"{line.strip()}")
        subprocess.run(["kill", pid], capture_output=True)
        reaped += 1
    return reaped


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scenario", action="append", default=[],
                        help="run only these scenario stems (repeatable); "
                             "default: all")
    parser.add_argument("--step-timeout", type=float,
                        default=STEP_TIMEOUT,
                        help="seconds allowed for each expected output "
                             "(default: %(default)s; real-timing fight "
                             "and sleep steps need several minutes)")
    args = parser.parse_args()

    scenario_paths = sorted(SCENARIO_DIR.glob("*.json"))
    if args.scenario:
        wanted = set(args.scenario)
        scenario_paths = [path for path in scenario_paths
                          if path.stem in wanted]
        if not scenario_paths:
            parser.error("no matching scenarios")

    failures = 0
    for scenario_path in scenario_paths:
        print(f"== {scenario_path.stem}")
        for variant in ("original", "tp7"):
            started = time.monotonic()
            try:
                run_scenario(variant, scenario_path,
                             args.step_timeout)
            except (RuntimeError, OSError) as error:
                print(f"  {variant}: FAILED: {error}")
                failures += 1
                continue
            print(f"  {variant}: scenario satisfied "
                  f"({time.monotonic() - started:.1f}s)")

    reaped = reap_dosemu()
    if reaped:
        print(f"reaped {reaped} leftover DOSEMU2 process(es)")
        failures += reaped

    total = 2 * len(scenario_paths)
    print(f"\n{total - failures}/{total} runtime smoke checks passed")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
