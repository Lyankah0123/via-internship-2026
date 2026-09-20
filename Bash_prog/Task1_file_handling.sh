#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task1_file_handling.sh
# @author       Louisa Yankah
# @index        7364423
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Demonstrates basic file handling: creating directories
#               and files, writing/appending content, reading, copying,
#               and safely deleting files with error handling throughout.
# @date         13th September 2026
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0 <target-directory>"
  echo "  <target-directory>  path to the directory to create/use"
  exit 1
}

# Validate input: exactly one argument required
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

if [[ -z "$1" ]]; then
  echo "Error: No target directory provided." >&2
  usage
fi

TARGET_DIR="$1"
FILE_NAME="sample.txt"
FILE_PATH="$TARGET_DIR/$FILE_NAME"
BACKUP_PATH="$FILE_PATH.bak"

# Step 1: Create the directory if it doesn't exist
if [[ -d "$TARGET_DIR" ]]; then
  echo "Directory '$TARGET_DIR' already exists."
else
  mkdir -p "$TARGET_DIR"
  if [[ $? -eq 0 ]]; then
    echo "Directory '$TARGET_DIR' created successfully."
  else
    echo "Error: Failed to create directory '$TARGET_DIR'. Check permissions." >&2
    exit 1
  fi
fi

# Step 2: Create a new file and write content to it
echo "This is the first line of content." > "$FILE_PATH"
if [[ $? -eq 0 ]]; then
  echo "File '$FILE_PATH' created and initial content written."
else
  echo "Error: Failed to write to '$FILE_PATH'." >&2
  exit 1
fi

# Step 3: Append additional content
echo "This is an appended second line." >> "$FILE_PATH"
if [[ $? -eq 0 ]]; then
  echo "Content appended successfully to '$FILE_PATH'."
else
  echo "Error: Failed to append to '$FILE_PATH'." >&2
  exit 1
fi

# Step 4: Read and display the file's contents
if [[ -f "$FILE_PATH" ]]; then
  echo "----- Contents of $FILE_PATH -----"
  cat "$FILE_PATH"
  echo "-----------------------------------"
else
  echo "Error: File '$FILE_PATH' does not exist, cannot read." >&2
  exit 1
fi

# Step 5: Copy the file to a .bak version
cp "$FILE_PATH" "$BACKUP_PATH"
if [[ $? -eq 0 ]]; then
  echo "Backup created at '$BACKUP_PATH'."
else
  echo "Error: Failed to create backup at '$BACKUP_PATH'." >&2
  exit 1
fi

# Step 6: Delete the original file only after confirming it exists
if [[ -f "$FILE_PATH" ]]; then
  echo "Confirming deletion: '$FILE_PATH' exists and will now be removed."
  rm "$FILE_PATH"
  if [[ $? -eq 0 ]]; then
    echo "Original file '$FILE_PATH' deleted successfully. Backup remains at '$BACKUP_PATH'."
  else
    echo "Error: Failed to delete '$FILE_PATH'." >&2
    exit 1
  fi
else
  echo "Error: '$FILE_PATH' does not exist, skipping deletion." >&2
  exit 1
fi

exit 0
