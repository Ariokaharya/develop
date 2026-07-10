#!/usr/bin/env bash
# postCreateCommand: runs once per new Codespace instance (after prebuild
# resume too), unlike onCreateCommand which prebuild caches. Good place for
# anything that should reflect "this specific instance".
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
source .devcontainer/scripts/lib.sh

run_stage "postCreateCommand:record-env" bash .devcontainer/scripts/record-env.sh
run_stage "postCreateCommand:mark-persistence" bash .devcontainer/scripts/mark-persistence.sh "postCreate"

echo "postCreate done. See .devcontainer/logs/lifecycle.log for timings."
