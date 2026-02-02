#!/bin/bash
set -euo pipefail

# ---- settings ----
USER_NAME="etupr-admin"
PIDFILE="/run/etupr-black.pid"

# ---- 1) remove black xterm ----
if [ -f "$PIDFILE" ]; then
  pid="$(cat "$PIDFILE" 2>/dev/null || true)"
  if [ -n "${pid:-}" ] && kill -0 "$pid" >/dev/null 2>&1; then
    kill "$pid" >/dev/null 2>&1 || true
    sleep 0.2
    kill -9 "$pid" >/dev/null 2>&1 || true
  fi
  rm -f "$PIDFILE" >/dev/null 2>&1 || true
fi

# ---- 2) un-block radios ----
/usr/sbin/rfkill unblock bluetooth >/dev/null 2>&1 || true
/usr/sbin/rfkill unblock wifi      >/dev/null 2>&1 || true

# ---- 3) bring back services needed in RUN state ----
/usr/bin/systemctl start cups.service         >/dev/null 2>&1 || true
/usr/bin/systemctl start cups-browsed.service >/dev/null 2>&1 || true
/usr/bin/systemctl start ModemManager.service >/dev/null 2>&1 || true

# bluetooth daemon (optional; if you don't need BT at all, remove these 2 lines)
# Note: even if stopped in sleep, it may be auto-activated by dbus/wireplumber.
/usr/bin/systemctl start bluetooth.service >/dev/null 2>&1 || true

# ---- 4) CPU governor -> schedutil (best-effort) ----
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  [ -w "$f" ] && (echo schedutil > "$f" 2>/dev/null || true) || true
done

exit 0