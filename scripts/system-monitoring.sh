Here are some shell scripts to monitor key system parameters like CPU, memory, disk usage, network traffic, and running processes.

1. CPU Usage Monitoring
This script monitors CPU usage and logs it if it exceeds a specified threshold.

```bash
#!/bin/bash

THRESHOLD=80  # CPU usage threshold percentage

# Get CPU usage for the last 1 minute
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

echo "Current CPU usage is: $CPU_USAGE%"

if (( $(echo "$CPU_USAGE > $THRESHOLD" | bc -l) )); then
    echo "High CPU usage detected: $CPU_USAGE%" | tee -a /var/log/cpu_monitor.log
fi
```

2. Memory Usage Monitoring
This script checks the memory usage and logs it if it exceeds a specified threshold.

```bash
#!/bin/bash

THRESHOLD=80  # Memory usage threshold percentage

# Get memory usage
MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

echo "Current memory usage is: $MEMORY_USAGE%"

if (( $(echo "$MEMORY_USAGE > $THRESHOLD" | bc -l) )); then
    echo "High memory usage detected: $MEMORY_USAGE%" | tee -a /var/log/memory_monitor.log
fi
```

3. Disk Space Monitoring
This script monitors disk space usage on specified mount points and logs an alert if usage exceeds a threshold.

```bash
#!/bin/bash

THRESHOLD=80  # Disk usage threshold percentage
MOUNT_POINT="/"  # Change as needed

# Get disk usage
DISK_USAGE=$(df -h "$MOUNT_POINT" | grep -vE '^Filesystem' | awk '{print $5}' | sed 's/%//g')

echo "Current disk usage at $MOUNT_POINT: $DISK_USAGE%"

if [ "$DISK_USAGE" -gt "$THRESHOLD" ]; then
    echo "High disk usage detected on $MOUNT_POINT: $DISK_USAGE%" | tee -a /var/log/disk_monitor.log
fi
```

4. Network Traffic Monitoring
This script monitors incoming and outgoing network traffic on a specified network interface.

```bash
#!/bin/bash

INTERFACE="eth0"  # Specify your network interface

# Get network traffic data
RX_BYTES_BEFORE=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX_BYTES_BEFORE=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
sleep 1
RX_BYTES_AFTER=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX_BYTES_AFTER=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

# Calculate the difference
RX_RATE=$(( ($RX_BYTES_AFTER - $RX_BYTES_BEFORE) / 1024 ))
TX_RATE=$(( ($TX_BYTES_AFTER - $TX_BYTES_BEFORE) / 1024 ))

echo "Download speed: $RX_RATE KB/s, Upload speed: $TX_RATE KB/s"
```

5. Monitoring Running Processes
This script checks for specific processes and logs if they are not running.

```bash
#!/bin/bash

# Define a list of processes to monitor
PROCESSES=("nginx" "mysqld" "sshd")

for PROCESS in "${PROCESSES[@]}"; do
    if pgrep "$PROCESS" > /dev/null; then
        echo "$PROCESS is running"
    else
        echo "$PROCESS is NOT running" | tee -a /var/log/process_monitor.log
    fi
done
```

6. System Health Check Summary
This script combines CPU, memory, disk, and process checks into a single report.

```bash
#!/bin/bash

# CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
echo "CPU usage: $CPU_USAGE%"

# Memory usage
MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
echo "Memory usage: $MEMORY_USAGE%"

# Disk usage
DISK_USAGE=$(df -h / | grep -vE '^Filesystem' | awk '{print $5}' | sed 's/%//g')
echo "Disk usage: $DISK_USAGE%"

# Network usage (eth0)
RX_BYTES_BEFORE=$(cat /sys/class/net/eth0/statistics/rx_bytes)
TX_BYTES_BEFORE=$(cat /sys/class/net/eth0/statistics/tx_bytes)
sleep 1
RX_BYTES_AFTER=$(cat /sys/class/net/eth0/statistics/rx_bytes)
TX_BYTES_AFTER=$(cat /sys/class/net/eth0/statistics/tx_bytes)
RX_RATE=$(( ($RX_BYTES_AFTER - $RX_BYTES_BEFORE) / 1024 ))
TX_RATE=$(( ($TX_BYTES_AFTER - $TX_BYTES_BEFORE) / 1024 ))
echo "Network Download: $RX_RATE KB/s, Upload: $TX_RATE KB/s"

# Check for essential processes
PROCESSES=("nginx" "mysqld" "sshd")
for PROCESS in "${PROCESSES[@]}"; do
    if pgrep "$PROCESS" > /dev/null; then
        echo "$PROCESS is running"
    else
        echo "$PROCESS is NOT running"
    fi
done
```

Automate Monitoring with Cron
To run these scripts periodically:

1. Open the crontab editor:
   ```bash
   crontab -e
   ```
2. Add an entry to run the scripts at desired intervals, e.g., every 5 minutes:
   ```bash
   # Run every 5 minutes
   */5 * * * * /path/to/your/system_monitor_script.sh
   ```

These scripts help monitor system health by tracking usage and availability of system resources and key processes.