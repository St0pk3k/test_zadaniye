#!/bin/bash
set -euo pipefail

PROCESS_NAME="test"
STATE_FILE="/var/run/${PROCESS_NAME}.pid"
LOG_TAG="monitor_test"
MONITOR_URL="https://test.com/monitoring/test/api"

timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

pid=$(pgrep -x "$PROCESS_NAME" || true)

if [[ -n "$pid" ]]; then
  if [[ -f "$STATE_FILE" ]]; then
    old_pid=$(cat "$STATE_FILE")
    if [[ "$pid" != "$old_pid" ]]; then
      logger -t "$LOG_TAG" "$(timestamp) Процесс $PROCESS_NAME перезапущен (PID $old_pid -> $pid)"
    fi
  fi
  echo "$pid" > "$STATE_FILE"

  if ! curl -fsS -m 5 "$MONITOR_URL" >/dev/null 2>&1; then
    logger -t "$LOG_TAG" "$(timestamp) Сервер мониторинга недоступен"
  fi
fi
