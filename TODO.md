# BOMBKI tests - TODO

This file lists only remaining work.

## Remaining work

1. **Behavioral-conformance tests**: create original-versus-TP7 runtime
   checks, including MODE status/item output, commands, sleep,
   and save/load. DOSEMU2 is suitable for those behavior checks; DOSBox-X
   is for TP7 compilation and top-level testing. Host-native FPC results
   are not DOS behavior evidence. The startup-hint wait step (as in
   mode-smoke) is now in every scenario; six of nine pass. The three
   remaining expectation mismatches need ground-truth checks against
   the original game: garden-dispatch-smoke (no ZYSKALES practice-gain
   messages at startup), mode-save-load-smoke (load flow passes the
   `suckemall:` prompt at BOMBKI.PAS:1370 before the money report),
   poster-reward-smoke (GORA from the cage hall returns to the round
   salon, not the poster room).

2. **Coverage growth**: raise total FPC line coverage from the
   18.58% baseline (six passing scenarios) toward the 100% goal,
   guided by the uncovered-lines report of
   `python3 tools/coverage_callgrind.py`; add scenarios for the
   untested paths (combat, items, death, and the rest of the
   command set). Use `--fail-under 100` as the gate once coverage
   reaches 100%.
