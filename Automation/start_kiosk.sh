#!/bin/bash
set -euo pipefail

# Start kiosk app and browser with required services enabled.
USER_NAME="etupr-admin"
USER_UID="1000"
PROJECT_DIR="/home/etupr-admin/Desktop/3etupr-signage"
VENV_PY="/home/etupr-admin/Desktop/3etupr-signage/.venv/bin/python"
APP_PY="/home/etupr-admin/Desktop/3etupr-signage/app.py"
PORT="8080"
URL="http://127.0.0.1:${PORT}"
CHROMIUM="/usr/bin/chromium"
DISPLAY_NUM=":0"
XAUTH="/home/${USER_NAME}/.Xauthority"
XDG_RUNTIME_DIR="/run/user/${USER_UID}"
RUNDIR="/run/signage"
APP_PID_FILE="${RUNDIR}/app.pid"
CHROME_PID_FILE="${RUNDIR}/chromium.pid"
mkdir -p "${RUNDIR}"

# Power on display and radios needed for kiosk operation.
/usr/bin/vcgencmd display_power 1 >/dev/null 2>&1 || true
/usr/sbin/rfkill unblock bluetooth >/dev/null 2>&1 || true
systemctl start bluetooth >/dev/null 2>&1 || true

# Restore CPU governor for normal performance.
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do [ -w "$f" ] && echo schedutil > "$f" || true; done

# Start background services used by the device.
systemctl start cups >/dev/null 2>&1 || true; systemctl start cups-browsed >/dev/null 2>&1 || true; systemctl start ModemManager >/dev/null 2>&1 || true

# Ensure old app process is gone, then start the Flask app and record its PID.
[ -f "${APP_PID_FILE}" ] && kill -0 "$(cat "${APP_PID_FILE}")" 2>/dev/null && kill "$(cat "${APP_PID_FILE}")" || true; sleep 1 || true; [ -f "${APP_PID_FILE}" ] && kill -9 "$(cat "${APP_PID_FILE}")" 2>/dev/null || true; rm -f "${APP_PID_FILE}"
cd "${PROJECT_DIR}"; runuser -u "${USER_NAME}" -- "${VENV_PY}" "${APP_PY}" & echo $! > "${APP_PID_FILE}"

# Wait for the app to accept connections before launching browser.
for _ in $(seq 1 80); do (echo >"/dev/tcp/127.0.0.1/${PORT}") >/dev/null 2>&1 && break || true; sleep 0.25; done

# Ensure old Chromium is gone, then launch kiosk window pointing at the app.
[ -f "${CHROME_PID_FILE}" ] && kill -0 "$(cat "${CHROME_PID_FILE}")" 2>/dev/null && kill "$(cat "${CHROME_PID_FILE}")" || true; sleep 1 || true; [ -f "${CHROME_PID_FILE}" ] && kill -9 "$(cat "${CHROME_PID_FILE}")" 2>/dev/null || true; rm -f "${CHROME_PID_FILE}"
runuser -u "${USER_NAME}" -- env DISPLAY="${DISPLAY_NUM}" XAUTHORITY="${XAUTH}" XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}" "${CHROMIUM}" --kiosk --app="${URL}" --noerrdialogs --disable-infobars "${URL}" & echo $! > "${CHROME_PID_FILE}"
exit 0
