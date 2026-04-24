#!/bin/bash

# --- Configuration ---
# Target display output name
OUTPUT="HDMI-A-1"
# Path to the log file
LOG_FILE="/tmp/display-controller.log"
# Retrieve the first argument (on/off)
ACTION=$1

# Ensure wlr-randr is installed on the system
if ! command -v wlr-randr &> /dev/null; then
    echo "$(date): ERROR - wlr-randr command not found." >> "$LOG_FILE"
    exit 1
fi

# Execute action based on the provided argument
case "$ACTION" in
    on)
        echo "Transitioning ${OUTPUT} to ON..."
        if wlr-randr --output "$OUTPUT" --on; then
            echo "$(date): SUCCESS - ${OUTPUT} turned ON" >> "$LOG_FILE"
        else
            echo "$(date): FAILED - Could not turn ON ${OUTPUT}" >> "$LOG_FILE"
            exit 1
        fi
        ;;
    off)
        echo "Transitioning ${OUTPUT} to OFF..."
        if wlr-randr --output "$OUTPUT" --off; then
            echo "$(date): SUCCESS - ${OUTPUT} turned OFF" >> "$LOG_FILE"
        else
            echo "$(date): FAILED - Could not turn OFF ${OUTPUT}" >> "$LOG_FILE"
            exit 1
        fi
        ;;
    *)
        # Display usage if the argument is missing or invalid
        echo "Usage: $0 {on|off}"
        exit 1
        ;;
esac
