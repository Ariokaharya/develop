#!/usr/bin/env bash
# B-2: report which markers are still present/what history survived.
# Run after each stop/resume, rebuild, or full-rebuild to fill in the matrix.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

WORKSPACE_MARKER=".devcontainer/logs/markers/workspace.log"
HOME_MARKER="$HOME/.codespace-persistence-marker.log"
CONTAINER_OTHER_MARKER="/usr/local/share/.codespace-persistence-marker.log"
VOLUME_NAME="codespace-persistence-test"

show() {
  local label="$1" path="$2"
  echo "--- $label ($path) ---"
  if [ -f "$path" ]; then
    cat "$path"
  else
    echo "(missing — did not survive, or never created yet)"
  fi
  echo
}

show "workspace"       "$WORKSPACE_MARKER"
show "home"             "$HOME_MARKER"
show "container-other"  "$CONTAINER_OTHER_MARKER"

echo "--- docker volume ($VOLUME_NAME) ---"
if command -v docker >/dev/null 2>&1 && docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
  docker run --rm -v "${VOLUME_NAME}:/data" busybox cat /data/marker.log 2>/dev/null \
    || echo "(volume exists but marker.log missing)"
else
  echo "(missing — volume does not exist, or docker not ready)"
fi
