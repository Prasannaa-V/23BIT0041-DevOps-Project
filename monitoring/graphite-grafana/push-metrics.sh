#!/bin/bash
# ================================================================
# push-metrics.sh
# Pushes CPU, Memory, Network I/O, HTTP availability, response
# time, and uptime metrics to Graphite's carbon plaintext receiver.
#
# Schedule via cron (every minute):
#   * * * * * /full/path/to/push-metrics.sh >> /var/log/push-metrics.log 2>&1
#
# Requirements: netcat (nc), curl, awk, free, ip/ifconfig
# ================================================================

GRAPHITE_HOST="${GRAPHITE_HOST:-localhost}"
GRAPHITE_PORT="${GRAPHITE_PORT:-2003}"
APP_URL="${APP_URL:-http://localhost:8081}"   # Adjust to your running site URL
IFACE="${NETWORK_IFACE:-eth0}"               # Network interface to monitor

NOW=$(date +%s)

# ── CPU load (1-min load average) ────────────────────────────────
CPU_LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | awk -F, '{ print $1 }' | xargs)

# ── Memory usage (%) ─────────────────────────────────────────────
MEM_USED_PCT=$(free | awk '/Mem:/ {printf "%.2f", $3/$2 * 100}')

# ── Network I/O (bytes) ──────────────────────────────────────────
# Read /proc/net/dev for interface RX/TX byte counts
if [ -f /proc/net/dev ]; then
  NET_RX=$(awk -v iface="$IFACE" '$1 ~ iface { gsub(/:/, "", $1); print $2 }' /proc/net/dev 2>/dev/null || echo 0)
  NET_TX=$(awk -v iface="$IFACE" '$1 ~ iface { gsub(/:/, "", $1); print $10 }' /proc/net/dev 2>/dev/null || echo 0)
else
  NET_RX=0
  NET_TX=0
fi

# ── HTTP availability & response time ────────────────────────────
HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" --max-time 5 "$APP_URL/health")
RESPONSE_TIME_MS=$(curl -o /dev/null -s -w "%{time_total}" --max-time 5 "$APP_URL/health" | awk '{printf "%.0f", $1*1000}')

if [ "$HTTP_CODE" = "200" ]; then
  HTTP_UP=1
else
  HTTP_UP=0
fi

# ── Uptime % (rolling 1-min window using /proc/uptime) ───────────
# uptime_percent = fraction of last minute the service was up (simplified: same as HTTP_UP * 100)
UPTIME_PCT=$(echo "$HTTP_UP * 100" | bc)

# ── Send all metrics to Graphite ─────────────────────────────────
{
  echo "abc_website.system.cpu_load $CPU_LOAD $NOW"
  echo "abc_website.system.memory_used_percent $MEM_USED_PCT $NOW"
  echo "abc_website.system.network_rx_bytes $NET_RX $NOW"
  echo "abc_website.system.network_tx_bytes $NET_TX $NOW"
  echo "abc_website.system.uptime_percent $UPTIME_PCT $NOW"
  echo "abc_website.http.available $HTTP_UP $NOW"
  echo "abc_website.http.response_time_ms $RESPONSE_TIME_MS $NOW"
} | nc -q1 "$GRAPHITE_HOST" "$GRAPHITE_PORT"

echo "[$(date)] Metrics pushed — cpu=$CPU_LOAD mem=${MEM_USED_PCT}% rx=${NET_RX}B tx=${NET_TX}B http_up=$HTTP_UP resp=${RESPONSE_TIME_MS}ms uptime=${UPTIME_PCT}%"
