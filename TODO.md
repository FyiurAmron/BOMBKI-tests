# BOMBKI tests - TODO

This file lists only remaining work.

## Remaining work

1. **Behavioral-conformance tests**: create original-versus-TP7 runtime
   checks, including MODE status/item output, commands, sleep,
   and save/load. DOSEMU2 is suitable for those behavior checks; DOSBox-X
   is for TP7 compilation and top-level testing. Host-native FPC results
   are not DOS behavior evidence.

2. **Coverage pipeline**: automate line-coverage measurement for the
   host-native FPC build. There is no FPC-native gcov equivalent
   (gcov/lcov/gcovr require GCC instrumentation; Delphi coverage
   tools are Windows/Delphi-only). Baseline: build with `-gw4` DWARF
   info, run `tests/expect_pty.py` scenarios under Valgrind Callgrind,
   use `callgrind_annotate --auto=yes` to map executed instructions to
   source lines, merge per-run results, and report per-unit line
   percentages against the 100% goal. gprof (`-pg`) covers functions
   only, not lines. TP7/DOS-side assurance stays with the byte-identical
   TPU/EXE comparison in `tests/compare_tpu.py`.
