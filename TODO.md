# BOMBKI tests - TODO

This file lists only remaining work.

## Remaining work

1. **Coverage growth**: raise total FPC line coverage from the
   33.75% level (nine passing scenario runs plus the Pascal unit
   tests) toward the 100% goal, guided by the
   uncovered-lines report of
   `python3 tools/coverage_callgrind.py`; add scenarios for the
   untested paths (combat, items, death, and the rest of the
   command set) and Pascal unit tests for the deterministic
   unit internals. Use `--fail-under 100` as the gate once
   coverage reaches 100%.

2. **Pascal unit tests**: `tests/units` holds the plain-Pascal
   test framework (`bkitest.pas`) and the first test program
   (`test_przedm.pas`, 33 tests: MODE, KOMENDY, TRAIN,
   POTWORY ranges, TARCZA, BRANIE, UZYWANIE item round-trips,
   drop-item invariants, scene messages), built and run
   host-native by `tests/run_unit_tests.py` and merged into
   the Callgrind coverage (PRZEDM.PAS 170 -> 340 lines).
   Next: WALKA's deterministic stat arithmetic, the SWIAT
   room procedures (they read commands from stdin, so the
   runner must pipe input), MONSTRA.WSTEP (waits for a
   keypress), and running the same test sources under
   genuine TP7 in DOSEMU2.

## Completed

- **Behavioral-conformance runtime checks** (done): all nine
  scenarios run against both the retained original
  (`_reference/BOMBKI.EXE`) and the genuine TP7 rebuild
  (`build/tp7/BOMBKI.EXE`) under DOSEMU2's terminal frontend,
  driven through the PTY harness (`tests/dosemu_game.sh` +
  `tests/expect_pty.py --pyte`) by `tests/dosemu_scenarios.py`;
  18/18 checks pass, covering MODE status/item output, commands,
  sleep, and save/load. The game seeds Random from the clock, so
  room population text varies per run; the scenarios match it
  loosely and no transcript equality is asserted. This is the
  final-check gate (before pushing or in CI), per the AGENTS.md
  check tiers. The three scenarios written against early
  experimental recon versions were corrected to the current
  PAS/EXE behavior: startup prints no ZYSKALES practice-gain
  messages (those live in ZdobadzPoziom, the level-up path), the
  load flow consumes one input line at BOMBKI.PAS:1278 before
  the `suckemall:` prompt at BOMBKI.PAS:1370, and the poster
  room is reached via rooms 1-4-5-9-11-17 (GORA from room 3
  returns to room 1, not to the cage hall).
