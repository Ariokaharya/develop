#!/usr/bin/env bash
# onCreateCommand: runs once when the container is first created, and is the
# stage that prebuilds execute ahead of time (B-1). Keep this idempotent and
# free of anything that must reflect "this instance" (that belongs in
# post-create.sh / post-start.sh instead), since prebuilds cache this step's
# result.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
source .devcontainer/scripts/lib.sh

run_stage "onCreateCommand" bash -c '
  set -e
  docker version >/dev/null   # confirms docker-in-docker feature is functional
  node --version >/dev/null   # confirms node feature is functional
'
