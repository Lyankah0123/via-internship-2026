#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task2_permissions_sudo.sh
# @author       Louisa Yankah
# @index        7364423
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Reports and modifies file permissions (numeric & symbolic),
#               and demonstrates root-only chown behavior gracefully.
# @date         13th September 2026
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0 <file-path>"
  echo "  <file-path>  path to an existing file to inspect/modify"
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

if [[ -z "$1" ]]; then
  echo "Error: No file path provided." >&2
  usage
fi

FILE_PATH="$1"

if [[ ! -e "$FILE_PATH" ]]; then
  echo "Error: '$FILE_PATH' does not exist." >&2
  exit 1
fi

report_permissions() {
  local label="$1"
  echo "----- $label -----"
  ls -l "$FILE_PATH"
  local numeric
  numeric=$(stat -c "%a" "$FILE_PATH" 2>/dev/null)
  if [[ $? -eq 0 ]]; then
    echo "Numeric permissions: $numeric"
  else
    echo "Error: Could not read numeric permissions." >&2
  fi
}

# Step 1: Report current permissions
report_permissions "BEFORE changes"

# Step 2: Demonstrate numeric chmod
chmod 644 "$FILE_PATH"
if [[ $? -eq 0 ]]; then
  echo "Applied numeric permissions (644) successfully."
else
  echo "Error: Failed to apply numeric chmod 644." >&2
  exit 1
fi

# Step 2b: Demonstrate symbolic chmod
chmod u+x "$FILE_PATH"
if [[ $? -eq 0 ]]; then
  echo "Applied symbolic permission change (u+x) successfully."
else
  echo "Error: Failed to apply symbolic chmod u+x." >&2
  exit 1
fi

# Step 3: Check if running as root, attempt chown if so
if [[ "$(id -u)" -eq 0 ]]; then
  echo "Running as root - attempting chown to root:root."
  chown root:root "$FILE_PATH"
  if [[ $? -eq 0 ]]; then
    echo "Ownership changed successfully."
  else
    echo "Error: chown failed even though running as root." >&2
  fi
else
  echo "Skipping chown: root privileges are required for this step, and this script is not running as root."
fi

# Step 4: Report permissions after changes
report_permissions "AFTER changes"

exit 0
                                           
