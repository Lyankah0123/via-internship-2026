#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task4_return_codes_error_handling.sh
# @author       Louisa Yankah
# @index        7364423
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Runs a sequence of system checks (host reachability, disk
#               space, file existence, command availability), exiting with
#               documented, specific codes on failure. Cleans up temp files
#               on exit via trap.
# @date         13th September 2026
# -----------------------------------------------------------------

# Exit codes:
#   0 = all checks passed
#   1 = missing required argument
#   2 = host unreachable
#   3 = insufficient disk space
#   4 = required file not found
#   5 = required command not found

usage() {
  echo "Usage: $0 <hostname>"
  echo "  <hostname>  a host to check reachability for, e.g. google.com"
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

if [[ -z "$1" ]]; then
  echo "Error: No hostname provided." >&2
  usage
fi

HOST="$1"
TMP_FILE=$(mktemp)

# Clean up temp file on exit, whether success, failure, or Ctrl+C
cleanup() {
  rm -f "$TMP_FILE"
  echo "Cleanup complete: temporary file removed."
}
trap cleanup EXIT

check_status() {
  local result=$1
  local pass_msg=$2
  local fail_msg=$3
  local exit_code=$4

  if [[ $result -eq 0 ]]; then
    echo "PASS: $pass_msg"
  else
    echo "FAIL: $fail_msg" >&2
    exit "$exit_code"
  fi
}

echo "Running system checks for host: $HOST"
echo "Temporary working file: $TMP_FILE"
echo ""

# Check 1: Host reachability
ping -c 1 -W 2 "$HOST" > "$TMP_FILE" 2>&1
check_status $? "Host '$HOST' is reachable." "Host '$HOST' is unreachable." 2

# Check 2: Sufficient disk space (at least 1GB free on /)
AVAILABLE_KB=$(df / | awk 'NR==2 {print $4}')
if [[ "$AVAILABLE_KB" -ge 1048576 ]]; then
  DISK_CHECK=0
else
  DISK_CHECK=1
fi
check_status $DISK_CHECK "Sufficient disk space available (>=1GB free on /)." "Insufficient disk space on /." 3

# Check 3: Required file exists and is readable
CONFIG_FILE="/etc/hosts"
if [[ -f "$CONFIG_FILE" && -r "$CONFIG_FILE" ]]; then
  FILE_CHECK=0
else
  FILE_CHECK=1
fi
check_status $FILE_CHECK "Required file '$CONFIG_FILE' exists and is readable." "Required file '$CONFIG_FILE' not found or unreadable." 4

# Check 4: Required command is installed
REQUIRED_CMD="curl"
command -v "$REQUIRED_CMD" > /dev/null 2>&1
check_status $? "Required command '$REQUIRED_CMD' is installed." "Required command '$REQUIRED_CMD' is not installed." 5

echo ""
echo "All checks passed successfully."
exit 0
