# Linux System Monitor with Telegram Alerts

This repository contains Bash scripts to monitor Linux system metrics (like CPU usage, memory usage, load averages, etc.) and send updates or alerts to a Telegram chat via a bot.

## Features

- **System Metrics Monitoring**:
  - Load Average
  - CPU Usage (including total CPUs)
  - Memory Usage
  - Swap Usage
  - Uptime
  - Running Tasks
- **Top Resource-Consuming Processes**:
  - Lists the top 5 processes consuming the most CPU and memory.
- **Telegram Alerts**:
  - Sends a detailed update or alert to a specified Telegram chat using a bot.

## Scripts

### 1. `monitor_overload.sh`
- **Purpose**: Monitors system metrics and sends alerts if thresholds are exceeded.
- **Thresholds**:
  - Load Average: `4.0`
  - CPU Usage: `80%`
  - Memory Usage: `80%`
- **Alert Details**:
  - Includes metrics exceeding thresholds and top 5 processes.

### 2. `send_load_to_telegram.sh`
- **Purpose**: Sends current system metrics and top 5 processes to Telegram without checking thresholds.

## Requirements

- A Telegram bot and chat ID.
- Utilities used:
  - `awk`, `curl`, `free`, `mpstat`, `ps`, `uptime`, `sed`

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
📊 System Metrics Update:

*Load Average:* 0.39 0.55 0.65
*CPU Usage:* 10.05% (active, Total CPUs: 8)
*Memory Usage:* 4.2Gi / 30Gi (13.70%)
*Swap Usage:* 2.0Mi / 4.0Gi
*Uptime:* 58 minutes
*Tasks:* 209

*Top 5 Processes:*
*PID:* 60949 *Name:* systemd-journal *MEM:* 0.2% *CPU:* 28.4%
*PID:* 1214 *Name:* nginx *MEM:* 6.9% *CPU:* 10.0%
*PID:* 1711 *Name:* rsyslogd *MEM:* 0.0% *CPU:* 5.8%
*PID:* 79312 *Name:* kworker/5:0-eve *MEM:* 0.0% *CPU:* 1.8%
*PID:* 78745 *Name:* kworker/4:2-eve *MEM:* 0.0% *CPU:* 1.6%
```

### Alert Example:
```
📊 System Metrics Update:

*Load Average:* 4.50 3.80 2.90
*CPU Usage:* 85.00% (active, Total CPUs: 8)
*Memory Usage:* 25.5Gi / 30Gi (85.00%)
*Swap Usage:* 2.0Gi / 4.0Gi
*Uptime:* 2 hours, 30 minutes
*Tasks:* 315

🚨 *Alert:* Load Average exceeds threshold (4.0).
🚨 *Alert:* CPU Usage exceeds threshold (80%).
🚨 *Alert:* Memory Usage exceeds threshold (80%).

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
