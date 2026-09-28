#!/usr/bin/env bash
# test.sh - tests for the diagnostic-tool Docker image

set -u
IMAGE="diagnostic-tool"
PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

echo "===== Testing $IMAGE ====="

# help
if docker run --rm "$IMAGE" help >/tmp/test-help.log 2>&1; then
  grep -qi "Commands:" /tmp/test-help.log && pass "help shows usage" || fail "help output missing usage text"
else
  fail "help command failed"
  cat /tmp/test-help.log
fi

# system
if docker run --rm "$IMAGE" system >/tmp/test-system.log 2>&1; then
  grep -qi "Hostname:" /tmp/test-system.log && pass "system shows system info" || fail "system output missing expected fields"
else
  fail "system command failed"
  cat /tmp/test-system.log
fi

# disk
if docker run --rm "$IMAGE" disk >/tmp/test-disk.log 2>&1; then
  grep -qi "Disk Information" /tmp/test-disk.log && pass "disk shows disk info" || fail "disk output missing expected header"
else
  fail "disk command failed"
  cat /tmp/test-disk.log
fi

# invalid command
docker run --rm "$IMAGE" bogus >/tmp/test-invalid.log 2>&1
rc=$?
if [[ $rc -ne 0 ]]; then
  pass "invalid command returns non-zero (exit $rc)"
else
  fail "invalid command should return non-zero"
fi

echo
echo "===== Results ====="
echo "Passed: $PASS"
echo "Failed: $FAIL"
[[ $FAIL -eq 0 ]]
