# BOMBKI tests - TODO

This file lists only remaining work.

## Remaining work

1. **DOSEMU2 full-fidelity gate**: raise `STEP_TIMEOUT` in
   `tests/dosemu_scenarios.py` (21 fight steps in 16 scenarios
   exceed 60 s under real timing, worst about 5.6 min), then run
   the original-variant scenarios (TP7 conformance dropped as
   too tedious; TP7 reproduction with exact seeds is an
   unverified assumption, not a checked fact).
