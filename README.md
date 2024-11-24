# Linux System Monitor with Telegram Alerts

This repository contains Bash scripts to monitor Linux system metrics (like CPU usage, memory usage, disk usage, etc.) and send updates or alerts to a Telegram chat via a bot.

## Features

- **System Metrics Monitoring**:
  - Load Average
  - CPU Usage (including total CPUs)
  - Memory Usage
  - Swap Usage
  - Disk Usage (with type: HDD, SSD, or SSD NVMe)
  - Uptime
  - Running Tasks
  - IP Address of the system
- **Network Speed Monitoring**:
  - RX/TX Speed (in kB/s and MB/s)
  - Max Network Speed (in Mbps)
- **Top Resource-Consuming Processes**:
  - Lists the top 5 processes consuming the most CPU and memory.
- **Telegram Alerts**:
  - Sends a detailed update or alert to a specified Telegram chat using a bot.
  - Alerts include metrics exceeding thresholds, such as:
    - High Load Average
    - High CPU Usage
    - High Memory Usage
    - High Disk Usage
  - Highlights critical metrics with clear alert messages.

## Scripts

### 1. `monitor_overload.sh`
- **Purpose**: Monitors system metrics and sends alerts if thresholds are exceeded.
- **Thresholds**:
  - Load Average: `4.0`
  - CPU Usage: `80%`
  - Memory Usage: `80%`
  - Disk Usage: `80%`
- **Alert Details**:
  - Includes metrics exceeding thresholds and top 5 processes.
  - Disk usage alerts if usage exceeds the defined threshold.
  - Provides alerts for Load Average, CPU Usage, Memory Usage, and Disk Usage.

### 2. `send_load_to_telegram.sh`
- **Purpose**: Sends current system metrics, disk usage, network speed, and top 5 processes to Telegram without checking thresholds.

## Requirements

- A Telegram bot and chat ID.
- Utilities used:
  - `awk`, `curl`, `free`, `mpstat`, `ps`, `uptime`, `df`, `lsblk`, `sed`, `sar`, `ethtool`, `hostname`

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/syntaxsurge/linux-system-monitor-telegram.git
   cd linux-system-monitor-telegram
   ```

2. Create a Telegram bot and get the `BOT_TOKEN` and `CHAT_ID`.
   - Follow [Telegram Bot API Guide](https://core.telegram.org/bots#creating-a-new-bot) to create a bot.

3. Edit the scripts:
   - Update `BOT_TOKEN` and `CHAT_ID` with your bot's token and chat ID in both scripts.

4. Make the scripts executable:
   ```bash
   chmod +x monitor_overload.sh send_load_to_telegram.sh
   ```

5. Test the scripts:
   - Send an update:
     ```bash
     ./send_load_to_telegram.sh
     ```
   - Monitor and alert:
     ```bash
     ./monitor_overload.sh
     ```

6. Automate with Cron (optional):
   - Add `monitor_overload.sh` to `crontab` for periodic monitoring:
     ```bash
     crontab -e
     ```
   - Example cron entry to run every minute:
     ```
     * * * * * /path/to/monitor_overload.sh >/dev/null 2>&1
     ```

## Example Output

### System Update:
```
📊 *System Load Update:*

*IP Address:* 192.168.1.1
*Load Average:* 0.48 0.55 0.55
*CPU Usage:* 7.47% (active, Total CPUs: 8)
*Memory Usage:* 6.2Gi / 30Gi (19.93%)
*Swap Usage:* 116Mi / 4.0Gi (2.84%)
*Disk Usage:* 138G / 911G (16% used)
*Disk Type:* SSD (NVMe)
*Uptime:* 1 day, 16 hours, 38 minutes
*Tasks:* 209
*Network Speed:* RX: 469.25 kB/s, TX: 26769.74 kB/s
*Max Network Speed:* 1000Mb/s

*Top 5 Processes:*
*PID:* 60949 *Name:* systemd-journal *MEM:* 0.3% *CPU:* 29.0%
*PID:* 1214 *Name:* nginx *MEM:* 13.6% *CPU:* 7.3%
*PID:* 1711 *Name:* rsyslogd *MEM:* 0.1% *CPU:* 6.3%
*PID:* 280653 *Name:* kworker/5:0-eve *MEM:* 0.0% *CPU:* 1.2%
*PID:* 280032 *Name:* kworker/6:2-eve *MEM:* 0.0% *CPU:* 1.0%
```

### Alert Example:
```
📊 *System Load Update:*

*IP Address:* 192.168.1.1
*Load Average:* 4.50 3.80 2.90
*CPU Usage:* 85.00% (active, Total CPUs: 8)
*Memory Usage:* 25.5Gi / 30Gi (85.00%)
*Swap Usage:* 3.5Gi / 4.0Gi (87.50%)
*Disk Usage:* 200Gi / 256Gi (85% used)
*Disk Type:* SSD
*Uptime:* 2 hours, 30 minutes
*Tasks:* 315
*Network Speed:* RX: 150.75 kB/s, TX: 120.30 kB/s
*Max Network Speed:* 1000 Mbps

🚨 *Alert:* *Load Average* exceeds threshold (4.0).
🚨 *Alert:* *CPU Usage* exceeds threshold (80%).
🚨 *Alert:* *Memory Usage* exceeds threshold (80%).
🚨 *Alert:* *Disk Usage* exceeds threshold (80%).

*Top 5 Processes:*
*PID:* 12345 *Name:* java *MEM:* 15.5% *CPU:* 70.3%
*PID:* 67890 *Name:* mysqld *MEM:* 10.8% *CPU:* 50.0%
*PID:* 11223 *Name:* apache2 *MEM:* 8.5% *CPU:* 30.0%
*PID:* 44556 *Name:* python *MEM:* 5.2% *CPU:* 20.5%
*PID:* 77889 *Name:* nginx *MEM:* 3.5% *CPU:* 15.0%
```

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License.
