#!/usr/bin/env bash
# Shared helpers for devcontainer lifecycle scripts.
# LOG_DIR lives under /workspaces so it survives container rebuilds (B-2 check)
# but is git-ignored so it never gets committed.

LOG_DIR="${LOG_DIR:-$(pwd)/.devcontainer/logs}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/lifecycle.log}"

mkdir -p "$LOG_DIR"

log_event() {
  local stage="$1"
  local status="$2"
  printf '%s\tstage=%s\tstatus=%s\thost=%s\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$stage" "$status" "$(hostname)" >> "$LOG_FILE"
}

run_stage() {
  local stage="$1"
  shift
  log_event "$stage" "start"
  if "$@"; then
    log_event "$stage" "ok"
  else
    local code=$?
    log_event "$stage" "FAILED(exit=$code)"
    return "$code"
  fi
}
