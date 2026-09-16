#!/bin/sh

URL="http://localhost:8000/data.txt"
LOGFILE="/home/ykke/asgn_poller/poller/logs/poller.log"

while true
do
    DATA=$(curl -fsS --max-time 5 "$URL")

    if [ $? -eq 0 ]; then

        TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

        TEMPERATURE=$(echo "$DATA" | grep "^temperature=")
        CITY=$(echo "$DATA" | grep "^city=")
        STATUS=$(echo "$DATA" | grep "^status=")

        echo "$TIMESTAMP | $TEMPERATURE | $CITY | $STATUS" >> "$LOGFILE"

        echo "[$TIMESTAMP] Poll successful"

    else

        TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

        echo "[$TIMESTAMP] Poll failed"

    fi

    sleep 5
done