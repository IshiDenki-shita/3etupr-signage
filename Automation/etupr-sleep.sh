#!/bin/bash
set -euo pipefail

# ---- settings ----
USER_NAME="etupr-admin"
WAYLAND_DISPLAY="wayland-0"
OUTPUT_NAME="HDMI-A-1"

# ---- 1) stop signage processes ----
/usr/bin/systemctl stop signage-browser.service >/dev/null 2>&1 || true
/usr/bin/systemctl stop signage-app.service     >/dev/null 2>&1 || true

# ---- 2) HDMI 出力を OFF ----
if command -v wlr-randr >/dev/null 2>&1; then
  WAYLAND_DISPLAY="$WAYLAND_DISPLAY" wlr-randr --output "$OUTPUT_NAME" --off || true
fi

# ---- 3) reduce background services ----
/usr/bin/systemctl stop cups-browsed.service >/dev/null 2>&1 || true
/usr/bin/systemctl stop cups.service         >/dev/null 2>&1 || true
/usr/bin/systemctl stop ModemManager.service >/dev/null 2>&1 || true

# ---- 4) bluetooth ----
/usr/sbin/rfkill block bluetooth >/dev/null 2>&1 || true
/usr/bin/systemctl stop bluetooth.service >/dev/null 2>&1 || true

# ---- 5) CPU governor ----
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  [ -w "$f" ] && echo powersave > "$f" 2>/dev/null || true
done

exit 0