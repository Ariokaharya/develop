#!/usr/bin/env bash
# A-2: capture machine spec + a repeatable "build" timing so the same
# comparison can be run on hand machine / 2-core / 4-core Codespaces.
# Safe to re-run any time: `bash .devcontainer/scripts/record-env.sh`
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
source .devcontainer/scripts/lib.sh

OUT_DIR=".devcontainer/logs/env"
mkdir -p "$OUT_DIR"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_FILE="$OUT_DIR/${STAMP}.txt"

{
  echo "== date =="; date -u
  echo "== lscpu =="; lscpu 2>&1 || echo "lscpu not available"
  echo "== free -h =="; free -h 2>&1 || echo "free not available"
  echo "== df -h /workspaces =="; df -h /workspaces 2>&1 || df -h "$(pwd)"
  echo
  echo "== this repo has no build/test pipeline of its own (static HTML/CSS/JS) =="
  echo "== using 'docker compose build' as the stand-in clean-build timing metric =="
  echo "== substitute your real project's 'make build' / test command here when validating against it =="
} > "$OUT_FILE"

echo "recorded spec snapshot: $OUT_FILE"

log_event "record-env" "start"
docker compose down --rmi local >/dev/null 2>&1 || true
BUILD_START=$(date +%s)
if docker compose build --no-cache >> "$OUT_FILE" 2>&1; then
  BUILD_STATUS=ok
else
  BUILD_STATUS=FAILED
fi
BUILD_END=$(date +%s)
{
  echo
  echo "== docker compose build --no-cache: ${BUILD_STATUS}, $((BUILD_END - BUILD_START))s =="
} >> "$OUT_FILE"
log_event "record-env" "$BUILD_STATUS"

echo "clean build finished: $BUILD_STATUS. See $OUT_FILE for timing."
