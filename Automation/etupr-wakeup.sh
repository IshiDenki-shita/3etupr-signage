#!/bin/bash
set -euo pipefail
/usr/bin/vcgencmd display_power 1 >/dev/null 2>&1 || true
/usr/sbin/rfkill unblock bluetooth >/dev/null 2>&1 || true
/usr/bin/systemctl start bluetooth.service >/dev/null 2>&1 || true
/usr/bin/systemctl start cups.service >/dev/null 2>&1 || true
/usr/bin/systemctl start cups-browsed.service >/dev/null 2>&1 || true
/usr/bin/systemctl start ModemManager.service >/dev/null 2>&1 || true
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do [ -w "$f" ] && echo schedutil > "$f" || true; done
exit 0