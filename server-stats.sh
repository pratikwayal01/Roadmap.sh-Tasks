#!/bin/bash
export LC_ALL=C

echo "Server Performance Stats"
echo "------------------------"

# 1. CPU Usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{print 100 - $1}')
echo "1. Total CPU Usage: ${cpu_usage}%"

# 2. Memory Usage
memory_stats=$(free -m | awk '/Mem:/ {print $2,$3,$4,$7}')
memory_total=$(echo $memory_stats | awk '{print $1}')
memory_used=$(echo $memory_stats | awk '{print $2}')
memory_free=$(echo $memory_stats | awk '{print $3}')
memory_available=$(echo $memory_stats | awk '{print $4}')

if [ -n "$memory_available" ]; then
    memory_percent=$(awk "BEGIN {printf \"%.2f\", ($memory_total - $memory_available)/$memory_total * 100}")
else
    memory_percent=$(awk "BEGIN {printf \"%.2f\", $memory_used/$memory_total * 100}")
fi

echo "2. Memory Usage:"
echo "   Total: ${memory_total}MB"
echo "   Used: ${memory_used}MB"
echo "   Free: ${memory_free}MB"
echo "   Usage: ${memory_percent}%"

# 3. Disk Usage
echo "3. Disk Usage:"
df -h / | awk 'NR==2 {printf "   Total: %s\n   Used: %s\n   Free: %s\n   Usage: %s\n", $2, $3, $4, $5}'

# 4. Top 5 CPU Processes
echo "4. Top 5 processes by CPU usage:"
ps -eo pid,ppid,user,%cpu,%mem,cmd --sort=-%cpu | head -n 6 | awk 'NR==1 {printf "   %-6s %-6s %-8s %-6s %-6s %s\n", $1, $2, $3, $4, $5, $6} NR>1 {printf "   %-6s %-6s %-8s %-6s %-6s %s\n", $1, $2, $3, $4, $5, substr($0, index($0,$6))}'

# 5. Top 5 Memory Processes
echo "5. Top 5 processes by memory usage:"
ps -eo pid,ppid,user,%mem,%cpu,cmd --sort=-%mem | head -n 6 | awk 'NR==1 {printf "   %-6s %-6s %-8s %-6s %-6s %s\n", $1, $2, $3, $4, $5, $6} NR>1 {printf "   %-6s %-6s %-8s %-6s %-6s %s\n", $1, $2, $3, $4, $5, substr($0, index($0,$6))}'

# 6. Additional Stats
echo "6. Additional Statistics:"

# OS Version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "   OS Version:    $PRETTY_NAME"
else
    echo "   OS Version:    Unknown"
fi

# Uptime
echo "   System Uptime: $(uptime -p | sed 's/up //')"

# Load Average
load_avg=$(uptime | awk -F'load average: ' '{print $2}')
echo "   Load Average:  ${load_avg}"

# Logged-in Users
echo "   Logged-in Users:"
who | awk '{printf "      %-10s %-15s %s\n", $1, $2, $3 " " $4}'

# Failed Logins
echo -n "   Failed Login Attempts: "
if [ -r /var/log/auth.log ]; then
    count=$(grep -c "Failed password" /var/log/auth.log 2>/dev/null)
elif [ -r /var/log/secure ]; then
    count=$(grep -c "Failed password" /var/log/secure 2>/dev/null)
else
    count="N/A (insufficient permissions)"
fi
echo "${count:-0}"

echo "------------------------"
