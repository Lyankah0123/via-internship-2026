#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task5_crud_app.sh
# @author       Louisa Yankah
# @index        7364423
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Menu-driven Todo List CRUD app. Stores data in a CSV file.
#               Fields: ID, Task Description, Status, Due Date.
# @date         13th September 2026
# -----------------------------------------------------------------

DATA_FILE="todo_data.csv"
BACKUP_FILE="todo_data.csv.bak"

usage() {
  echo "Usage: $0"
  echo "  Runs an interactive Todo List CRUD app. No arguments needed."
  exit 0
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

# Ensure data file exists
if [[ ! -f "$DATA_FILE" ]]; then
  echo "ID,Task,Status,DueDate" > "$DATA_FILE"
  if [[ $? -ne 0 ]]; then
    echo "Error: Could not create data file '$DATA_FILE'." >&2
    exit 1
  fi
fi

backup_data() {
  cp "$DATA_FILE" "$BACKUP_FILE"
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to back up data file before destructive change." >&2
    return 1
  fi
  return 0
}

next_id() {
  local last_id
  last_id=$(tail -n +2 "$DATA_FILE" | cut -d',' -f1 | sort -n | tail -1)
  if [[ -z "$last_id" ]]; then
    echo 1
  else
    echo $((last_id + 1))
  fi
}

add_task() {
  local desc status due id
  read -rp "Enter task description: " desc
  if [[ -z "$desc" ]]; then
    echo "Error: Task description cannot be empty." >&2
    return 1
  fi
  read -rp "Enter status (pending/done) [default: pending]: " status
  status=${status:-pending}
  read -rp "Enter due date (optional, e.g. 2026-09-20): " due

  id=$(next_id)
  echo "$id,$desc,$status,$due" >> "$DATA_FILE"
  if [[ $? -eq 0 ]]; then
    echo "Task added successfully with ID $id."
  else
    echo "Error: Failed to add task." >&2
    return 1
  fi
}

list_tasks() {
  if [[ $(wc -l < "$DATA_FILE") -le 1 ]]; then
    echo "No tasks found."
    return 0
  fi
  echo "----------------------------------------"
  printf "%-4s %-30s %-10s %-12s\n" "ID" "Task" "Status" "Due Date"
  echo "----------------------------------------"
  tail -n +2 "$DATA_FILE" | while IFS=',' read -r id desc status due; do
    printf "%-4s %-30s %-10s %-12s\n" "$id" "$desc" "$status" "$due"
  done
  echo "----------------------------------------"
}

search_task() {
  local keyword
  read -rp "Enter keyword to search for: " keyword
  if [[ -z "$keyword" ]]; then
    echo "Error: Search keyword cannot be empty." >&2
    return 1
  fi
  local matches
  matches=$(tail -n +2 "$DATA_FILE" | grep -i "$keyword")
  if [[ -z "$matches" ]]; then
    echo "No matching tasks found for '$keyword'."
  else
    echo "----------------------------------------"
    printf "%-4s %-30s %-10s %-12s\n" "ID" "Task" "Status" "Due Date"
    echo "----------------------------------------"
    echo "$matches" | while IFS=',' read -r id desc status due; do
      printf "%-4s %-30s %-10s %-12s\n" "$id" "$desc" "$status" "$due"
    done
  fi
}

update_task() {
  local id found newdesc newstatus newdue
  read -rp "Enter the ID of the task to update: " id
  if [[ -z "$id" ]]; then
    echo "Error: ID cannot be empty." >&2
    return 1
  fi
  found=$(grep "^$id," "$DATA_FILE")
  if [[ -z "$found" ]]; then
    echo "Error: Task with ID $id not found." >&2
    return 1
  fi

  backup_data || return 1

  read -rp "Enter new description (leave blank to keep unchanged): " newdesc
  read -rp "Enter new status (leave blank to keep unchanged): " newstatus
  read -rp "Enter new due date (leave blank to keep unchanged): " newdue

  local old_desc old_status old_due
  IFS=',' read -r _ old_desc old_status old_due <<< "$found"

  newdesc=${newdesc:-$old_desc}
  newstatus=${newstatus:-$old_status}
  newdue=${newdue:-$old_due}

  grep -v "^$id," "$DATA_FILE" > "${DATA_FILE}.tmp" && \
    echo "$id,$newdesc,$newstatus,$newdue" >> "${DATA_FILE}.tmp" && \
    mv "${DATA_FILE}.tmp" "$DATA_FILE"

  if [[ $? -eq 0 ]]; then
    echo "Task $id updated successfully."
  else
    echo "Error: Failed to update task $id." >&2
    return 1
  fi
}

delete_task() {
  local id found confirm
  read -rp "Enter the ID of the task to delete: " id
  if [[ -z "$id" ]]; then
    echo "Error: ID cannot be empty." >&2
    return 1
  fi
  found=$(grep "^$id," "$DATA_FILE")
  if [[ -z "$found" ]]; then
    echo "Error: Task with ID $id not found." >&2
    return 1
  fi

  read -rp "Are you sure you want to delete task $id? (y/n): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Deletion cancelled."
    return 0
  fi

  backup_data || return 1

  grep -v "^$id," "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  if [[ $? -eq 0 ]]; then
    echo "Task $id deleted successfully."
  else
    echo "Error: Failed to delete task $id." >&2
    return 1
  fi
}

show_menu() {
  echo ""
  echo "===== Todo List CRUD App ====="
  echo "1) Add task"
  echo "2) View/List tasks"
  echo "3) Search tasks"
  echo "4) Update task"
  echo "5) Delete task"
  echo "6) Exit"
  echo "==============================="
}

while true; do
  show_menu
  read -rp "Choose an option (1-6): " choice
  case "$choice" in
    1) add_task ;;
    2) list_tasks ;;
    3) search_task ;;
    4) update_task ;;
    5) delete_task ;;
    6)
      echo "Goodbye!"
      exit 0
      ;;
    *)
      echo "Invalid option. Please choose between 1 and 6." >&2
      ;;
  esac
done
