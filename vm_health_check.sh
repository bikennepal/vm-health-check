#!/bin/bash

# vm_health_check.sh: Basic VM health check script

# Usage:
#   ./vm_health_check.sh           # Basic health summary
#   ./vm_health_check.sh --explain # Detailed summary

explain=false
if [[ "$1" == "--explain" ]]; then
  explain=true
fi

# CPU Check
cpu_load=$(awk '{print $1}' <(uptime | awk -F'[a-z]:' '{ print $2 }'))
cpu_count=$(nproc)
cpu_status="OK"
if (( $(echo "$cpu_load > $cpu_count" | bc -l) )); then
  cpu_status="High load"
fi

# Memory Check
mem_total=$(free -m | awk '/Mem:/ {print $2}')
mem_used=$(free -m | awk '/Mem:/ {print $3}')
mem_percent=$(( 100 * mem_used / mem_total ))
mem_status="OK"
if [ "$mem_percent" -ge 85 ]; then
  mem_status="High memory usage"
fi

# Disk Check (root partition)
disk_total=$(df -h / | awk 'NR==2 {print $2}')
disk_used=$(df -h / | awk 'NR==2 {print $3}')
disk_percent=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
disk_status="OK"
if [ "$disk_percent" -ge 90 ]; then
  disk_status="Low disk space"
fi

# Summary Output
echo "===== VM Health Summary ====="
echo "CPU Load: $cpu_load ($cpu_status)"
echo "Memory Usage: $mem_used MB / $mem_total MB ($mem_status)"
echo "Disk Usage: $disk_used / $disk_total ($disk_status)"

if $explain; then
  echo
  echo "===== Detailed Explanation ====="
  echo "CPU:"
  echo " - $cpu_load is the average load in the past minute."
  echo " - $cpu_count CPUs available."
  echo " - If load exceeds CPU count, the system may be overloaded."
  echo
  echo "Memory:"
  echo " - $mem_used MB used out of $mem_total MB."
  echo " - Usage over 85% is considered high."
  echo
  echo "Disk:"
  echo " - $disk_used used of $disk_total total on root (/)."
  echo " - Usage over 90% triggers a warning."
fi

exit 0