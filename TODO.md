# BOMBKI tests - TODO

This file lists only remaining work.

## Remaining work

1. **Coverage growth**: PRZEDM.PAS, MONSTRA.PAS, and SWIAT.PAS
   are at 100% of their reachable lines. The reproducible total is
   **90.14%** (BOMBKI.PAS 81.92%, 359 of its lines remaining),
   measured by `python3 tools/coverage_callgrind.py
   --dump-uncovered` over 31 scenarios plus the Pascal unit
   tests. That figure is stable: two consecutive runs give a
   byte-identical uncovered set, because the coverage build stubs
   both crt.Delay and the System PRNG (`tools/build_dev_game.py`),
   so rolls no longer drift with the clock. All that remains is
   BOMBKI.PAS: the command dispatch, the per-room handlers, and
   save/load. Use `--fail-under 100` as the gate once it reaches
   100%, then run the DOSEMU2 full-fidelity gate.

2. **Pascal unit tests**: `tests/units` holds the plain-Pascal
   test framework (`pastest.pas`) and the first test program
   (`test_przedm.pas`, 115 tests: MODE, KOMENDY, TRAIN,
   POTWORY ranges, TARCZA, BRANIE, UZYWANIE item round-trips,
   drop-item invariants, scene messages, WALKA stat arithmetic,
   WALKA special moves (parry, fireball, poison, poison
   damage over time, super kop, flee, potrawki, death, fukroll
   redraw, dodges, and the parry and potrawki skill lessons
   that need a zero draw), the encounter procedures (SLABO
   through BTRUDNO, including their rare heart drops), and the
   rare-gain branches of the loot
   procedures, the stdin-driven ReadLn procedures (PIERDOLY's
   ZMIEN TLO branch and POROWNANIE: every monster group and
   every MONSTRA.OGOL band, driven by one stdin line per
   call), and the MINIARENA
   ZABIJ branches (all 28 arena monsters, split into four
   per-encounter-type tests so each command string stays under
   the 255-char ShortString limit and ends in MODE so the arena
   loop exits cleanly instead of spinning at EOF) and the
   MINIARENA EXIT and navigation branches (one EXIT per room
   case plus each of the four movement commands), and the
   FIGHTSCENA and FIGHTBLUSZCZ branches (the four musician
   ZABIJ fights, all twelve bluszcz ZABIJ fights, the
   SECRET LISTA / KUP DOKUMENT / KUP PLECAK shop, and
   ROZMAWIAJ DUNCAN at DUNQ = 0 and -125, driven by
   setting the wpisz global), built and run host-native by
   `tests/run_unit_tests.py` and merged into the Callgrind
   coverage (PRZEDM.PAS 170 -> 1259 of 1259 reachable lines;
   the WALKA tests
   run in milliseconds because the runner links a Delay
   stub that wraps the crt unit's Delay). Two execution
   modes, per AGENTS.md: development runs use the modded
   FPC native build with a stubbed crt.Delay (fast and
   approximate, the only mode for repeated scenario runs),
   while the full-fidelity acceptance gate runs the
   original EXE and the genuine TP7 build under DOSEMU2
   with real timing, and runs only once coverage reaches
   100%. Never run more than one scenario at a time.
   PRZEDM's SMIERC is
   never called in the original and is not in the unit
   interface, so no test can reach it; the coverage tool
   excludes such never-called procedures instead of changing
   the reconstructed source. A second program
   (`test_swiat.pas`, 19 tests) covers the SWIAT room
   procedures, which loop on ReadLn until MIECHO leaves the
   room: each test sets MIECHO to the room id, pipes that
   room's commands in through standard input (the same
   FeedStdin helper the PRZEDM tests use), and ends with a
   command that leaves the room, so the loop terminates
   instead of spinning at EOF. That covers the exit lists and
   poster text of every room, the room-13 monster fight with
   its sword, shield, and heart drops and its flee path, and
   the whole quest-master road (the three quest purchases,
   all three hand-ins, the blocked and open west road, the
   quest list, and killing the master). Next: the BOMBKI.PAS
   command dispatch, room walking, and save/load paths, plus
   MONSTRA.WSTEP (waits for a keypress), and running the same
   test sources under genuine TP7 in DOSEMU2.

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
