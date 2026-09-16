#!/bin/sh
# poller.sh - polls the web service and logs the fields we care about
set -u

WEB_URL="${WEB_URL:-http://web:8000/data.txt}"
INTERVAL="${INTERVAL:-5}"
LOG_FILE="${LOG_FILE:-/var/log/poller/poller.log}"
MAX_RETRIES="${MAX_RETRIES:-5}"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "$(date -u +'%Y-%m-%dT%H:%M:%SZ') $1" | tee -a "$LOG_FILE"
}

log "poller starting, target=$WEB_URL interval=${INTERVAL}s"

retries=0

while true; do
    response=$(curl --silent --show-error --fail --max-time 5 \
        --write-out "HTTPSTATUS:%{http_code}" "$WEB_URL" 2>/tmp/curl_err)
    curl_exit=$?

    if [ $curl_exit -ne 0 ]; then
        err_msg=$(cat /tmp/curl_err)
        retries=$((retries + 1))
        log "ERROR curl_exit=$curl_exit retries=$retries msg=\"$err_msg\""

        if [ "$retries" -ge "$MAX_RETRIES" ]; then
            log "WARN service unreachable after $MAX_RETRIES attempts, will keep trying"
            retries=0
        fi

        sleep "$INTERVAL"
        continue
    fi

    http_status=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d':' -f2)
    body=$(echo "$response" | sed -e 's/HTTPSTATUS:[0-9]*//')

    if [ "$http_status" != "200" ]; then
        log "ERROR non-200 response status=$http_status"
        sleep "$INTERVAL"
        continue
    fi

    retries=0

    temperature=$(echo "$body" | grep '^temperature=' | cut -d'=' -f2)
    city=$(echo "$body" | grep '^city=' | cut -d'=' -f2)
    status=$(echo "$body" | grep '^status=' | cut -d'=' -f2)

    log "OK status=$http_status temperature=${temperature:-NA} city=${city:-NA} weather_status=${status:-NA}"

    sleep "$INTERVAL"
done