#!/usr/bin/env bash
# A-1: quick reachability probe for domains commonly required by GitHub
# Codespaces / VS Code. Run this FROM THE CORPORATE NETWORK (e.g. in a
# terminal on a laptop connected via the office proxy/VPN, or from a Codespace
# if you're trying to spot what's blocked from the *inside*) before doing any
# real Codespaces evaluation, since a firewall block here makes every other
# checklist item moot.
#
# IMPORTANT: this list is a reasonable starting point based on commonly
# documented GitHub Codespaces / VS Code requirements, NOT a guaranteed
# complete or current list — cross-check against GitHub's official current
# "allowlisting Codespaces" documentation, since these domains do change
# over time and vary with which extensions/features you actually use.
# Treat this script as a fast first pass, and this checklist item (A-1) as the
# authoritative empirical record for your environment.
set -uo pipefail

DOMAINS=(
  "github.com"
  "api.github.com"
  "raw.githubusercontent.com"
  "objects.githubusercontent.com"
  "codeload.github.com"
  "github.dev"
  "vscode.dev"
  "marketplace.visualstudio.com"
  "vscode.blob.core.windows.net"
  "update.code.visualstudio.com"
  "ghcr.io"
  "pkg-containers.githubusercontent.com"
  "mcr.microsoft.com"
  "registry-1.docker.io"
  "auth.docker.io"
  "production.cloudflare.docker.com"
)

OUT_DIR=".devcontainer/logs/network"
mkdir -p "$OUT_DIR" 2>/dev/null || OUT_DIR="."
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_FILE="$OUT_DIR/${STAMP}.txt"

echo "checking ${#DOMAINS[@]} domains, writing results to $OUT_FILE"
{
  echo "# corporate network reachability check — $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  for d in "${DOMAINS[@]}"; do
    if curl --silent --head --max-time 5 --output /dev/null "https://${d}"; then
      printf '%-45s OK\n' "$d"
    else
      printf '%-45s BLOCKED_OR_UNREACHABLE\n' "$d"
    fi
  done
} | tee "$OUT_FILE"

echo
echo "Any BLOCKED_OR_UNREACHABLE line is what to hand to the network/proxy team."
echo "(On a Windows machine without curl, retest with: Test-NetConnection -ComputerName <domain> -Port 443)"
