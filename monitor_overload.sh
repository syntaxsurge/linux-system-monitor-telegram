#!/bin/bash

# Telegram Bot API details
BOT_TOKEN="xxxxx:xxxxx"
CHAT_ID="xxxxx"

# Define thresholds
MAX_LOAD=4.0        # Max acceptable load average
MAX_CPU=80          # Max CPU usage percentage
MAX_MEMORY=80       # Max memory usage percentage
MAX_DISK=80         # Max disk usage percentage

# Get system metrics
LOAD_AVG=$(awk '{print $1}' /proc/loadavg)
CPU_USAGE=$(mpstat 1 1 | awk '/Average:/ {printf "%.2f", 100 - $NF}')
TOTAL_CPUS=$(nproc)
MEMORY=$(free -h | awk '/Mem:/ {printf "%s / %s", $3, $2}')
MEMORY_PERCENT=$(free | awk '/Mem:/ {printf "%.2f", $3/$2 * 100}')
SWAP=$(free -h | awk '/Swap:/ {printf "%s / %s", $3, $2}')
SWAP_PERCENT=$(free | awk '/Swap:/ {if ($2 != 0) printf "%.2f", $3/$2 * 100; else printf "0.00"}')
UPTIME=$(uptime -p | sed 's/up //')  # Remove the "up" word
TASKS=$(ps -e --no-headers | wc -l)

# Disk usage
DISK_USAGE=$(df -h / | awk 'NR==2 {printf "%s / %s (%s used)", $3, $2, $5}')
DISK_USED_PERCENT=$(df / | awk 'NR==2 {gsub("%",""); print $5}')  # Extract percentage value only
DISK_TYPE=$(lsblk -o NAME,TYPE,ROTA | grep -E 'disk' | awk '{if ($3 == "1") print "HDD"; else if ($1 ~ "nvme") print "SSD (NVMe)"; else print "SSD"}' | head -n 1)

# Get IP address (removes hostname)
IP_ADDRESS=$(hostname -I | awk '{print $1}')  # Get the first IP address

# Network speed and usage
# Identify the primary network interface
NET_INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
if [[ -n $NET_INTERFACE ]]; then
    # Get current RX/TX speeds using 'sar'
    NETWORK_STATS=$(sar -n DEV 1 1 | grep "$NET_INTERFACE" | tail -1)
    RX_SPEED=$(echo "$NETWORK_STATS" | awk '{printf "%.2f kB/s", $5}')
    TX_SPEED=$(echo "$NETWORK_STATS" | awk '{printf "%.2f kB/s", $6}')
    
    # Get the maximum speed of the network interface using 'ethtool'
    MAX_SPEED=$(ethtool $NET_INTERFACE | grep "Speed" | awk '{print $2}')
else
    RX_SPEED="N/A"
    TX_SPEED="N/A"
    MAX_SPEED="N/A"
fi

# Get top 5 high resource-consuming processes
TOP_PROCESSES=$(ps -eo pid,comm,%mem,%cpu --sort=-%cpu | head -n 6 | awk 'NR>1 {printf "*PID:* %s *Name:* %s *MEM:* %s%% *CPU:* %s%%%s", $1, $2, $3, $4, "%0A"}')

# Sanitize the top processes message to avoid Markdown issues
TOP_PROCESSES=$(echo "$TOP_PROCESSES" | sed -E 's/([_`])//g')

# Prepare the message with URL-encoded newlines
MESSAGE="📊 *System Metrics Update:*%0A%0A"
MESSAGE+="*IP Address:* $IP_ADDRESS%0A"
MESSAGE+="*Load Average:* $LOAD_AVG%0A"
MESSAGE+="*CPU Usage:* $CPU_USAGE% (active, Total CPUs: $TOTAL_CPUS)%0A"
MESSAGE+="*Memory Usage:* $MEMORY ($MEMORY_PERCENT%)%0A"
MESSAGE+="*Swap Usage:* $SWAP ($SWAP_PERCENT%)%0A"
MESSAGE+="*Disk Usage:* $DISK_USAGE%0A"
MESSAGE+="*Disk Type:* $DISK_TYPE%0A"
MESSAGE+="*Uptime:* $UPTIME%0A"
MESSAGE+="*Tasks:* $TASKS%0A"
MESSAGE+="*Network Speed:* RX: $RX_SPEED, TX: $TX_SPEED%0A"
MESSAGE+="*Max Network Speed:* $MAX_SPEED%0A%0A"
MESSAGE+="*Top 5 Processes:*%0A$TOP_PROCESSES"

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

# Check for high disk usage
if (( $DISK_USED_PERCENT > $MAX_DISK )); then
    MESSAGE+="🚨 *Alert:* Disk Usage exceeds threshold ($MAX_DISK%).%0A"
    ALERT_FLAG=1
fi

# Sanitize the final message to avoid Markdown parsing issues
MESSAGE=$(echo "$MESSAGE" | sed -E 's/([_`])//g')

# Send the message only if at least one metric exceeds the threshold
if [[ $ALERT_FLAG -eq 1 ]]; then
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$MESSAGE" \
        -d parse_mode="Markdown"
fi
