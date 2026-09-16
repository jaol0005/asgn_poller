#!/bin/sh
while true; do
  response=$(curl -s -o /tmp/body -w "%{http_code}" http://web:8000/data.json)
  if [ "$response" = "200" ]; then
    value=$(jq -r '.value' /tmp/body)
    echo "$(date) - value: $value" >> /var/log/poller.log
  else
    echo "$(date) - error: HTTP $response" >> /var/log/poller.log
  fi
  sleep 5
done