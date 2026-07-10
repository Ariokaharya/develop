#!/usr/bin/env bash
# B-2: drop a timestamped marker in each candidate "does this survive?"
# location. Run manually before each stop/resume/rebuild/delete drill:
#   bash .devcontainer/scripts/mark-persistence.sh "before-stop-resume-1"
# then run check-persistence.sh after the operation to see what's still there.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

TAG="${1:-manual}"
STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
LINE="$(printf 'tag=%s\ttime=%s' "$TAG" "$STAMP")"

WORKSPACE_MARKER=".devcontainer/logs/markers/workspace.log"
HOME_MARKER="$HOME/.codespace-persistence-marker.log"
CONTAINER_OTHER_MARKER="/usr/local/share/.codespace-persistence-marker.log"
VOLUME_NAME="codespace-persistence-test"

mkdir -p "$(dirname "$WORKSPACE_MARKER")"
printf '%s\n' "$LINE" >> "$WORKSPACE_MARKER"
printf '%s\n' "$LINE" >> "$HOME_MARKER"
sudo mkdir -p "$(dirname "$CONTAINER_OTHER_MARKER")" 2>/dev/null || mkdir -p "$(dirname "$CONTAINER_OTHER_MARKER")"
(printf '%s\n' "$LINE" | sudo tee -a "$CONTAINER_OTHER_MARKER" >/dev/null) 2>/dev/null || printf '%s\n' "$LINE" >> "$CONTAINER_OTHER_MARKER"

if command -v docker >/dev/null 2>&1; then
  docker volume create "$VOLUME_NAME" >/dev/null
  docker run --rm -v "${VOLUME_NAME}:/data" busybox \
    sh -c "printf '%s\n' '$LINE' >> /data/marker.log" >/dev/null 2>&1 || \
    echo "WARN: could not write docker-volume marker (docker-in-docker not ready yet?)"
else
  echo "WARN: docker not available, skipped docker-volume marker"
fi

echo "markers written with tag='$TAG' at $STAMP"
echo "  workspace:        $WORKSPACE_MARKER"
echo "  home:             $HOME_MARKER"
echo "  container-other:  $CONTAINER_OTHER_MARKER"
echo "  docker volume:    $VOLUME_NAME (/data/marker.log)"
