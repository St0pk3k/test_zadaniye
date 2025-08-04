#!/bin/bash

logs="/var/log/monitoring.log"

pids="/var/run/test.pid"

pid=$(pgrep -x test)

if [[ -z "$pid" ]]; then
    exit 0
fi

if [[ ! -f "$pids" ]]; then
    echo "$pid" > "$pids"
else
    old_pid=$(cat "$pids")
    if [[ "$pid" != "$old_pid" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') — процесс перезапущен (pid изменился: $old_pid → $pid)" >> "$logs"
        echo "$pid" > "$pids"
    fi
fi

curl -s --head --connect-timeout 5 https://test.com/monitoring/test/api > /dev/null
if [[ $? -ne 0 ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') — сервер недоступен" >> "$logs"
fi
