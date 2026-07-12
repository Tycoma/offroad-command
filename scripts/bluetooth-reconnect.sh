#!/bin/bash

PHONE_MAC="C4:F7:C1:BA:87:63"
LOG_FILE="$HOME/passenger-display/logs/bluetooth-reconnect.log"
MAX_ATTEMPTS=12
WAIT_SECONDS=5

mkdir -p "$(dirname "$LOG_FILE")"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
}

log_message "Bluetooth reconnect started."

# Give the desktop audio session time to start.
sleep 8

bluetoothctl power on >> "$LOG_FILE" 2>&1
bluetoothctl trust "$PHONE_MAC" >> "$LOG_FILE" 2>&1

attempt=1

while [ "$attempt" -le "$MAX_ATTEMPTS" ]; do
    if bluetoothctl info "$PHONE_MAC" | grep -q "Connected: yes"; then
        log_message "Phone already connected."
        exit 0
    fi

    log_message "Connection attempt $attempt of $MAX_ATTEMPTS."

    bluetoothctl connect "$PHONE_MAC" >> "$LOG_FILE" 2>&1

    sleep 3

    if bluetoothctl info "$PHONE_MAC" | grep -q "Connected: yes"; then
        log_message "Phone connected successfully."
        exit 0
    fi

    attempt=$((attempt + 1))
    sleep "$WAIT_SECONDS"
done

log_message "Phone was not available after all attempts."
exit 0
