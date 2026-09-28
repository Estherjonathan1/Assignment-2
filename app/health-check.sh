#!/usr/bin/env bash
# health-check.sh - reports whether the diagnostic CLI is healthy
# Exit 0 if healthy, 1 otherwise. Intended for use as a Docker HEALTHCHECK.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIAGNOSTIC="$SCRIPT_DIR/diagnostic.sh"

if [[ ! -x "$DIAGNOSTIC" ]]; then
  echo "UNHEALTHY: diagnostic.sh not found or not executable at $DIAGNOSTIC"
  exit 1
fi

if "$DIAGNOSTIC" system >/dev/null 2>&1; then
  echo "HEALTHY: diagnostic.sh system command is working"
  exit 0
else
  echo "UNHEALTHY: diagnostic.sh system command failed"
  exit 1
fi
