#!/usr/bin/env bash
# diagnostic.sh - diagnostic CLI
# Usage: diagnostic <system|network|disk|help> [args]

set -u

usage() {
  cat <<'USAGE'
Usage: diagnostic <command> [args]

Commands:
  system            Display Linux system information
  network <host>    Check connectivity to a host
  disk              Display disk usage information
  help              Show this help message
USAGE
}

cmd_system() {
  echo "===== System Information ====="
  echo "Hostname:          $(hostname)"
  echo "Current user:      $(whoami)"
  echo "Date/time:         $(date)"
  echo "Operating system:  $(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || uname -s)"
  echo "Kernel version:    $(uname -r)"
  echo "Uptime:            $(uptime -p 2>/dev/null || uptime)"
  echo "CPU:               $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //') ($(nproc) cores)"
  echo "Memory:            $(free -h | awk '/^Mem:/ {print $3 " used / " $2 " total"}')"
  return 0
}

cmd_network() {
  local HOST="${1:-}"
  if [[ -z "$HOST" ]]; then
    echo "Error: network requires a host argument" >&2
    usage >&2
    return 2
  fi
  if ! [[ "$HOST" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ ]]; then
    echo "Error: invalid host: $HOST" >&2
    return 2
  fi
  local RESOLVED
  RESOLVED=$(getent ahosts "$HOST" 2>/dev/null | awk 'NR==1 {print $1}')
  if [[ -z "$RESOLVED" ]]; then
    echo "Resolution: FAILED - could not resolve $HOST"
    return 1
  fi
  echo "Resolved address: $RESOLVED"
  if command -v ping >/dev/null 2>&1 && ping -c 1 -W 2 "$HOST" >/dev/null 2>&1; then
    echo "Ping: OK"
    return 0
  else
    echo "Ping: FAILED"
    return 1
  fi
}

cmd_disk() {
  echo "===== Disk Information ====="
  df -h --output=target,size,used,avail,pcent 2>/dev/null || df -h
  return 0
}

if [[ $# -lt 1 ]]; then
  echo "Error: missing command" >&2
  usage >&2
  exit 2
fi

COMMAND="$1"
shift

case "$COMMAND" in
  system)
    cmd_system
    exit $?
    ;;
  network)
    cmd_network "$@"
    exit $?
    ;;
  disk)
    cmd_disk
    exit $?
    ;;
  help)
    usage
    exit 0
    ;;
  *)
    echo "Error: unknown command: $COMMAND" >&2
    usage >&2
    exit 2
    ;;
esac
