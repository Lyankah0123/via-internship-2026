#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task3_pipes_redirection.sh
# @author       Louisa Yankah
# @index        7364423
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Generates sample log data, then uses pipes and text tools
#               to summarize it: totals, counts by level, top IPs, errors.
# @date         13th September 2026
# -----------------------------------------------------------------

LOG_FILE="sample.log"
RESULTS_FILE="results.txt"
ERROR_FILE="errors.log"

# Step 1: Generate sample log data using a heredoc (50+ lines)
cat > "$LOG_FILE" << 'EOF'
2026-09-11 10:00:01 INFO 192.168.1.10 User login successful
2026-09-11 10:00:15 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:00:30 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:00:45 INFO 192.168.1.11 User logout successful
2026-09-11 10:01:00 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:01:15 INFO 192.168.1.12 User login successful
2026-09-11 10:01:30 WARN 192.168.1.14 High memory usage
2026-09-11 10:01:45 ERROR 192.168.1.15 Authentication failed
2026-09-11 10:02:00 INFO 192.168.1.10 File uploaded successfully
2026-09-11 10:02:15 INFO 192.168.1.16 User login successful
2026-09-11 10:02:30 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:02:45 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:03:00 INFO 192.168.1.17 User login successful
2026-09-11 10:03:15 ERROR 192.168.1.18 Authentication failed
2026-09-11 10:03:30 INFO 192.168.1.10 File downloaded successfully
2026-09-11 10:03:45 WARN 192.168.1.19 Disk usage above 80%
2026-09-11 10:04:00 INFO 192.168.1.20 User login successful
2026-09-11 10:04:15 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:04:30 INFO 192.168.1.10 User logout successful
2026-09-11 10:04:45 WARN 192.168.1.21 High memory usage
2026-09-11 10:05:00 ERROR 192.168.1.22 Authentication failed
2026-09-11 10:05:15 INFO 192.168.1.11 User login successful
2026-09-11 10:05:30 INFO 192.168.1.10 File uploaded successfully
2026-09-11 10:05:45 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:06:00 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:06:15 INFO 192.168.1.24 User login successful
2026-09-11 10:06:30 ERROR 192.168.1.25 Authentication failed
2026-09-11 10:06:45 INFO 192.168.1.10 User logout successful
2026-09-11 10:07:00 WARN 192.168.1.26 High memory usage
2026-09-11 10:07:15 INFO 192.168.1.12 User login successful
2026-09-11 10:07:30 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:07:45 INFO 192.168.1.10 File uploaded successfully
2026-09-11 10:08:00 WARN 192.168.1.27 Disk usage above 80%
2026-09-11 10:08:15 INFO 192.168.1.28 User login successful
2026-09-11 10:08:30 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:08:45 INFO 192.168.1.10 User logout successful
2026-09-11 10:09:00 WARN 192.168.1.29 High memory usage
2026-09-11 10:09:15 INFO 192.168.1.13 User login successful
2026-09-11 10:09:30 ERROR 192.168.1.30 Authentication failed
2026-09-11 10:09:45 INFO 192.168.1.10 File downloaded successfully
2026-09-11 10:10:00 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:10:15 INFO 192.168.1.31 User login successful
2026-09-11 10:10:30 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:10:45 INFO 192.168.1.10 User logout successful
2026-09-11 10:11:00 WARN 192.168.1.32 High memory usage
2026-09-11 10:11:15 INFO 192.168.1.14 User login successful
2026-09-11 10:11:30 ERROR 192.168.1.33 Authentication failed
2026-09-11 10:11:45 INFO 192.168.1.10 File uploaded successfully
2026-09-11 10:12:00 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:12:15 INFO 192.168.1.34 User login successful
2026-09-11 10:12:30 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:12:45 INFO 192.168.1.10 User logout successful
EOF

if [[ $? -ne 0 ]]; then
  echo "Error: Failed to generate sample log data." >&2
  exit 1
fi
echo "Sample log data generated at '$LOG_FILE' ($(wc -l < "$LOG_FILE") lines)."

# Clear previous results/errors files
> "$RESULTS_FILE"
> "$ERROR_FILE"

{
  echo "===== Log Summary Report ====="
  echo ""

  # 1. Total number of log lines
  echo "Total log lines:"
  wc -l < "$LOG_FILE"
  echo ""

  # 2. Count of lines per log level
  echo "Count per log level:"
  awk '{print $3}' "$LOG_FILE" | sort | uniq -c | sort -rn
  echo ""

  # 3. Top 3 most frequent IP addresses
  echo "Top 3 most frequent IP addresses:"
  awk '{print $4}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -3
  echo ""

  # 4. All ERROR lines
  echo "All ERROR lines:"
  grep "ERROR" "$LOG_FILE"
} > "$RESULTS_FILE" 2> "$ERROR_FILE"

if [[ $? -eq 0 ]]; then
  echo "Report generated successfully at '$RESULTS_FILE'."
else
  echo "Error: Something went wrong generating the report. Check '$ERROR_FILE'." >&2
  exit 1
fi

if [[ -s "$ERROR_FILE" ]]; then
  echo "Warning: Some errors were captured in '$ERROR_FILE'."
else
  echo "No errors encountered during report generation."
fi

exit 0
