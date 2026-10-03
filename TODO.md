# BOMBKI tests - TODO

This file lists only remaining work.

## Remaining work

1. **Behavioral-conformance tests**: create original-versus-TP7 runtime
   checks, including MODE status/item output, commands, sleep,
   and save/load. DOSEMU2 is suitable for those behavior checks; DOSBox-X
   is for TP7 compilation and top-level testing. Host-native FPC results
   are not DOS behavior evidence. All nine scenarios now pass natively.
   The three written against early experimental recon versions were
   corrected to the current PAS/EXE behavior: startup prints no ZYSKALES
   practice-gain messages (those live in ZdobadzPoziom, the level-up
   path), the load flow consumes one input line at BOMBKI.PAS:1278
   before the `suckemall:` prompt at BOMBKI.PAS:1370, and the poster
   room is reached via rooms 1-4-5-9-11-17 (GORA from room 3 returns
   to room 1, not to the cage hall).

2. **Coverage growth**: raise total FPC line coverage from the
   33.75% level (nine passing scenario runs plus the Pascal unit
   tests) toward the 100% goal, guided by the
   uncovered-lines report of
   `python3 tools/coverage_callgrind.py`; add scenarios for the
   untested paths (combat, items, death, and the rest of the
   command set) and Pascal unit tests for the deterministic
   unit internals. Use `--fail-under 100` as the gate once
   coverage reaches 100%.

3. **Pascal unit tests**: `tests/units` holds the plain-Pascal
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
