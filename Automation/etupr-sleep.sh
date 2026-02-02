#!/bin/bash
set -euo pipefail
/usr/bin/systemctl stop cups-browsed.service >/dev/null 2>&1 || true
/usr/bin/systemctl stop cups.service >/dev/null 2>&1 || true
/usr/bin/systemctl stop ModemManager.service >/dev/null 2>&1 || true
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do [ -w "$f" ] && (echo powersave > "$f" 2>/dev/null || echo schedutil > "$f" 2>/dev/null || true) || true; done
/usr/bin/vcgencmd display_power 0 >/dev/null 2>&1 || true
exit 0