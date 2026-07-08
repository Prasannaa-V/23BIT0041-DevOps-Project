#!/bin/bash
# Pushes basic CPU, memory, and HTTP availability metrics to Graphite's carbon receiver.
# Run this via cron every minute, e.g:
#   * * * * * /path/to/push-metrics.sh
#
# Requires: netcat (nc), curl, bc

GRAPHITE_HOST="localhost"
GRAPHITE_PORT=2003
APP_URL="http://localhost:8081"   # your website's URL (adjust to your NodePort/host mapping)
NOW=$(date +%s)

# CPU usage (%) - 1 minute load average as a simple proxy
CPU_LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | awk -F, '{ print $1 }' | xargs)

# Memory usage (%)
MEM_USED_PCT=$(free | awk '/Mem:/ {printf "%.2f", $3/$2 * 100}')

# HTTP availability check (1 = up, 0 = down) and response time in ms
HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" --max-time 5 "$APP_URL/health")
RESPONSE_TIME_MS=$(curl -o /dev/null -s -w "%{time_total}" --max-time 5 "$APP_URL/health" | awk '{printf "%.0f", $1*1000}')

if [ "$HTTP_CODE" == "200" ]; then
  HTTP_UP=1
else
  HTTP_UP=0
fi

# Send metrics to Graphite (metric.path value timestamp)
{
  echo "abc_website.system.cpu_load $CPU_LOAD $NOW"
  echo "abc_website.system.memory_used_percent $MEM_USED_PCT $NOW"
  echo "abc_website.http.available $HTTP_UP $NOW"
  echo "abc_website.http.response_time_ms $RESPONSE_TIME_MS $NOW"
} | nc -q1 "$GRAPHITE_HOST" "$GRAPHITE_PORT"

echo "Metrics pushed at $(date): cpu_load=$CPU_LOAD mem=$MEM_USED_PCT% http_up=$HTTP_UP resp=${RESPONSE_TIME_MS}ms"
