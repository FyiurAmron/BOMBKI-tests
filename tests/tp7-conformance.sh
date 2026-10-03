#!/bin/sh
#
# tp7-conformance.sh -- TP-mode conformance sweep for the BOMBKI
# reconstruction sources using the genuine Borland Turbo Pascal 7
# compiler (TPC.EXE) under DOSBox-X.
#
# Runs inside the bombki-dosbox-tp7 image (docker/dosbox-tp7/Dockerfile):
# /workspace is the checked-out repository mount. The reconstruction
# sources are copied to a scratch dir, converted to DOS line endings,
# compiled in dependency order with TPC.EXE driven through a generated
# DOSBox-X config, then the build log and the artifacts are checked.
# The compile happens in the scratch dir so nothing is written back
# into the repository.
#
# Fails the run if TPC reports errors, any artifact is missing, or the
# log does not show the genuine TP7 compiler banner.
# Requires: dosbox-x, xvfb-run (in the bombki-dosbox-tp7 image).

set -u

WORK=/workspace
PROJECT="$WORK"
REC="$WORK/_reconstructed"
mkdir -p "$PROJECT/build/tmp"
BUILD="$(mktemp -d "$PROJECT/build/tmp/tp7-conformance.XXXXXX")"
trap 'rm -rf "$BUILD"' EXIT

for c in dosbox-x xvfb-run find sed cp grep touch; do
  command -v "$c" >/dev/null 2>&1 || {
    echo "::error::$c missing in the bombki-dosbox-tp7 image" >&2
    exit 2
  }
done

# Current images extract TP7 into /tools/tp7; earlier published images use
# /opt/tp7. Search both so a still-cached `latest` image remains usable.
TPC="$(find /tools/tp7 /opt/tp7 -iname 'tpc.exe' 2>/dev/null | head -n1)"
if [ -z "$TPC" ]; then
  echo "::error::TPC.EXE not found under /tools/tp7 or /opt/tp7" >&2
  exit 2
fi
TP7ROOT="$(dirname "$(dirname "$TPC")")"
TPCDIR="$(basename "$(dirname "$TPC")")"
echo "TPC: $TPC"
echo "TP7 root: $TP7ROOT"

if ! cp "$REC/MONSTRA.PAS" "$REC/PRZEDM.PAS" "$REC/SWIAT.PAS" "$REC/BOMBKI.PAS" "$BUILD"/; then
  echo "::error::reconstruction sources not found under $REC" >&2
  exit 2
fi

# TPC expects DOS (CRLF) line endings; the reconstruction sources are LF-only.
sed -i 's/$/\r/' "$BUILD"/*.PAS

# TP7 embeds each source file's mtime in the unit's TPU source record, so the
# scratch copies get the original wall-clock times back after the CRLF rewrite.
#
# MONSTRA.TPU source record 0x03D2 stores DOS timestamp 0x26BB958B
# (1999-05-27 18:44:22); the 53-line source also preserves its line metadata.
# SWIAT.TPU source record 0x04CF stores DOS timestamp 0x26CC6711
# (1999-06-12 12:56:34); the 445-line source restores its per-line code counts.
# PRZEDM.TPU source record 0x1516 stores DOS timestamp 0x26C19BB0
# (1999-06-01 19:29:32).
touch -t 199905271844.22 "$BUILD/MONSTRA.PAS" || exit 2
touch -t 199906121256.34 "$BUILD/SWIAT.PAS" || exit 2
touch -t 199906011929.32 "$BUILD/PRZEDM.PAS" || exit 2

cat > "$BUILD/tp7-run.conf" <<EOF
[dosbox]
machine=svga_bridge
memsize=32

[cpu]
core=auto
cputype=pentium

[render]
frameskip=0

[sdl]
fullscreen=false
fulldouble=false
autolock=false

[mixer]
nosound=true

[dos]
ver=7.0

[autoexec]
mount c $TP7ROOT
mount d $BUILD
d:
c:\\$TPCDIR\\tpc.exe /GD monstra.pas > d:\\tp7-build.log
c:\\$TPCDIR\\tpc.exe /GD przedm.pas >> d:\\tp7-build.log
c:\\$TPCDIR\\tpc.exe /GD swiat.pas >> d:\\tp7-build.log
c:\\$TPCDIR\\tpc.exe /GD bombki.pas >> d:\\tp7-build.log
exit
EOF

xvfb-run -a dosbox-x -conf "$BUILD/tp7-run.conf"

LOG="$(find "$BUILD" -maxdepth 1 -iname 'tp7-build.log' | head -n1)"
if [ -z "$LOG" ] || [ ! -s "$LOG" ]; then
  echo "::error::no TPC build log produced (dosbox-x did not run TPC?)" >&2
  exit 1
fi

passed=0
failed=0

if grep -qE 'Turbo Pascal.*Version 7' "$LOG"; then
  echo "PASS  genuine TP7 compiler banner"
  passed=$((passed + 1))
else
  echo "FAIL  genuine TP7 compiler banner (log suspicious)"
  tail -n 30 "$LOG"
  failed=$((failed + 1))
fi

if grep -qiE 'error:|fatal:' "$LOG"; then
  echo "FAIL  TPC reported compile errors"
  tail -n 40 "$LOG"
  failed=$((failed + 1))
else
  echo "PASS  no TPC errors"
  passed=$((passed + 1))
fi

for name in MONSTRA.TPU PRZEDM.TPU SWIAT.TPU BOMBKI.EXE BOMBKI.MAP; do
  if find "$BUILD" -maxdepth 1 -iname "$name" -size +0c | grep -q .; then
    echo "PASS  $name produced"
    passed=$((passed + 1))
  else
    echo "FAIL  $name missing or empty"
    failed=$((failed + 1))
  fi
done

# Export artifacts for CI upload when CONF_ARTIFACTS is set. Non-fatal: the
# sweep verdict is about the TPC compile, not artifact plumbing.
if [ -n "${CONF_ARTIFACTS:-}" ]; then
  mkdir -p "$CONF_ARTIFACTS"
  for name in MONSTRA.TPU PRZEDM.TPU SWIAT.TPU BOMBKI.EXE BOMBKI.MAP; do
    found="$(find "$BUILD" -maxdepth 1 -iname "$name" -size +0c | head -n1)"
    if [ -n "$found" ]; then
      cp "$found" "$CONF_ARTIFACTS"/ && echo "artifact: $(basename "$found") -> $CONF_ARTIFACTS"
    fi
  done
fi

echo ""
echo "passed: $passed, failed: $failed"
if [ "$failed" -gt 0 ]; then
  echo "::error::TP7 conformance sweep failed ($failed target(s))"
  exit 1
fi
echo "conformance OK"
exit 0
