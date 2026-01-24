#!/bin/bash
set -euo pipefail

# Stop kiosk processes and related services so the device can idle safely.
USER_NAME="etupr-admin"
RUNDIR="/run/signage"
APP_PID_FILE="${RUNDIR}/app.pid"
CHROME_PID_FILE="${RUNDIR}/chromium.pid"

mkdir -p "${RUNDIR}"

# Stop Chromium gracefully, then force kill if it lingers; clean up kiosk-related processes for the user.
[ -f "${CHROME_PID_FILE}" ] && kill -0 "$(cat "${CHROME_PID_FILE}")" 2>/dev/null && kill "$(cat "${CHROME_PID_FILE}")" || true; sleep 1 || true; [ -f "${CHROME_PID_FILE}" ] && kill -9 "$(cat "${CHROME_PID_FILE}")" 2>/dev/null || true; pkill -u "${USER_NAME}" -f "/usr/bin/chromium.*--kiosk" 2>/dev/null || true; pkill -u "${USER_NAME}" -f "/usr/bin/chromium.*--app=" 2>/dev/null || true; rm -f "${CHROME_PID_FILE}"

# Stop the signage app PID gracefully, then force kill; remove the PID file.
[ -f "${APP_PID_FILE}" ] && kill -0 "$(cat "${APP_PID_FILE}")" 2>/dev/null && kill "$(cat "${APP_PID_FILE}")" || true; sleep 1 || true; [ -f "${APP_PID_FILE}" ] && kill -9 "$(cat "${APP_PID_FILE}")" 2>/dev/null || true; rm -f "${APP_PID_FILE}"

# Turn off radios and background daemons not needed when signage is stopped.
systemctl stop bluetooth >/dev/null 2>&1 || true; /usr/sbin/rfkill block bluetooth >/dev/null 2>&1 || true
systemctl stop cups >/dev/null 2>&1 || true; systemctl stop cups-browsed >/dev/null 2>&1 || true; systemctl stop ModemManager >/dev/null 2>&1 || true

# Drop CPU frequency to powersave to reduce power draw.
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do [ -w "$f" ] && echo powersave > "$f" || true; done

# Turn off HDMI output to blank the display.
/usr/bin/vcgencmd display_power 0 >/dev/null 2>&1 || true
exit 0
