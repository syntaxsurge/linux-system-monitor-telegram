#!/bin/bash

# Telegram Bot API details
BOT_TOKEN="xxxxx:xxxxx"
CHAT_ID="xxxxx"

# Define thresholds
MAX_LOAD=4.0        # Max acceptable load average
MAX_CPU=80          # Max CPU usage percentage
MAX_MEMORY=80       # Max memory usage percentage

# Get system metrics
LOAD_AVG=$(awk '{print $1}' /proc/loadavg)
CPU_USAGE=$(mpstat 1 1 | awk '/Average:/ {printf "%.2f", 100 - $NF}')
TOTAL_CPUS=$(nproc)
MEMORY=$(free -h | awk '/Mem:/ {printf "%s / %s", $3, $2}')
MEMORY_PERCENT=$(free | awk '/Mem:/ {printf "%.2f", $3/$2 * 100}')
SWAP=$(free -h | awk '/Swap:/ {printf "%s / %s", $3, $2}')
UPTIME=$(uptime -p | sed 's/up //')  # Remove the "up" word
TASKS=$(ps -e --no-headers | wc -l)

# Get top 5 high resource-consuming processes
TOP_PROCESSES=$(ps -eo pid,comm,%mem,%cpu --sort=-%cpu | head -n 6 | awk 'NR>1 {printf "*PID:* %s *Name:* %s *MEM:* %s%% *CPU:* %s%%%s", $1, $2, $3, $4, "%0A"}')

# Prepare the message with system metrics
MESSAGE="📊 *System Metrics Update:*%0A%0A"
MESSAGE+="*Load Average:* $LOAD_AVG%0A"
MESSAGE+="*CPU Usage:* $CPU_USAGE% (active, Total CPUs: $TOTAL_CPUS)%0A"
MESSAGE+="*Memory Usage:* $MEMORY ($MEMORY_PERCENT%)%0A"
MESSAGE+="*Swap Usage:* $SWAP%0A"
MESSAGE+="*Uptime:* $UPTIME%0A"
MESSAGE+="*Tasks:* $TASKS%0A%0A"

# Initialize a flag to track if any metric exceeds the threshold
ALERT_FLAG=0

# Check for high load average
if (( $(echo "$LOAD_AVG > $MAX_LOAD" | bc -l) )); then
    MESSAGE+="🚨 *Alert:* Load Average exceeds threshold ($MAX_LOAD).%0A"
    ALERT_FLAG=1
fi

# Check for high CPU usage
if (( $(echo "$CPU_USAGE > $MAX_CPU" | bc -l) )); then
    MESSAGE+="🚨 *Alert:* CPU Usage exceeds threshold ($MAX_CPU%).%0A"
    ALERT_FLAG=1
fi

# Check for high memory usage
if (( $(echo "$MEMORY_PERCENT > $MAX_MEMORY" | bc -l) )); then
    MESSAGE+="🚨 *Alert:* Memory Usage exceeds threshold ($MAX_MEMORY%).%0A"
    ALERT_FLAG=1
fi

# Include top 5 processes in the message
MESSAGE+="%0A*Top 5 Processes:*%0A$TOP_PROCESSES"

# Send the message only if at least one metric exceeds the threshold
if [[ $ALERT_FLAG -eq 1 ]]; then
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$MESSAGE" \
        -d parse_mode="Markdown"
fi
