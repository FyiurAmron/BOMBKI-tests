# BOMBKI tests - TODO

This file lists only remaining work.

## Remaining work

1. **DOSEMU2 full-fidelity gate**: raise `STEP_TIMEOUT` in
   `tests/dosemu_scenarios.py` (22 steps in 17 scenarios exceed
   60 s under real timing, up to ~83 min for `sleep-rounds`),
   then run the full original+TP7 gate (serial, budget about
   5 h), plus the Pascal unit-test sources under genuine TP7.
