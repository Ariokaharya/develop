#!/usr/bin/env bash
# postStartCommand: runs on every start/resume (stop->resume, rebuild->start),
# not just first creation. This is the timestamp trail for B-2 (resume timing)
# and B-3 (was this session actually stopped/restarted, or just idle).
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
source .devcontainer/scripts/lib.sh

log_event "postStartCommand" "start-or-resume"
bash .devcontainer/scripts/check-persistence.sh >> .devcontainer/logs/lifecycle.log 2>&1 || true
