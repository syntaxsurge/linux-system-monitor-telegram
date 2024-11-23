#!/bin/bash

# Telegram Bot API details
BOT_TOKEN="xxxxx:xxxxx"
CHAT_ID="xxxxx"

# Get system metrics
LOAD_AVG=$(awk '{print $1, $2, $3}' /proc/loadavg)
CPU_USAGE=$(mpstat 1 1 | awk '/Average:/ {printf "%.2f", 100 - $NF}')
TOTAL_CPUS=$(nproc)
MEMORY=$(free -h | awk '/Mem:/ {printf "%s / %s", $3, $2}')
MEMORY_PERCENT=$(free | awk '/Mem:/ {printf "%.2f", $3/$2 * 100}')
SWAP=$(free -h | awk '/Swap:/ {printf "%s / %s", $3, $2}')
UPTIME=$(uptime -p | sed 's/up //')  # Remove the "up" word
TASKS=$(ps -e --no-headers | wc -l)

# Get top 5 high resource-consuming processes
TOP_PROCESSES=$(ps -eo pid,comm,%mem,%cpu --sort=-%cpu | head -n 6 | awk 'NR>1 {printf "*PID:* %s *Name:* %s *MEM:* %s%% *CPU:* %s%%%s", $1, $2, $3, $4, "%0A"}')

# Sanitize the top processes message to avoid Markdown issues
TOP_PROCESSES=$(echo "$TOP_PROCESSES" | sed -E 's/([_`])//g')

# Prepare the message with URL-encoded newlines
MESSAGE="📊 *System Load Update:*%0A%0A"
MESSAGE+="*Load Average:* $LOAD_AVG%0A"
MESSAGE+="*CPU Usage:* $CPU_USAGE% (active, Total CPUs: $TOTAL_CPUS)%0A"
MESSAGE+="*Memory Usage:* $MEMORY ($MEMORY_PERCENT%)%0A"
MESSAGE+="*Swap Usage:* $SWAP%0A"
MESSAGE+="*Uptime:* $UPTIME%0A"
MESSAGE+="*Tasks:* $TASKS%0A%0A"
MESSAGE+="*Top 5 Processes:*%0A$TOP_PROCESSES"

# Escape special characters in MESSAGE
MESSAGE=$(echo "$MESSAGE" | sed -E 's/([_`])//g')

# Send the message to Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d text="$MESSAGE" \
    -d parse_mode="Markdown"
