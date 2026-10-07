# BOMBKI tests - TODO

This file lists only remaining work.

## Remaining work

1. **DOSEMU2 full-fidelity gate**: raise `STEP_TIMEOUT` in
   `tests/dosemu_scenarios.py` (21 fight steps in 16 scenarios
   exceed 60 s under real timing, worst about 5.6 min), then run
   the full original+TP7 gate (serial, budget about 2.5 h),
   plus the Pascal unit-test sources under genuine TP7.
