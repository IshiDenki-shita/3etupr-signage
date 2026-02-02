#!/bin/bash
set -euo pipefail

# ---- settings ----
USER_NAME="etupr-admin"
DISPLAY_NUM=":0"
XAUTH="/home/${USER_NAME}/.Xauthority"
PIDFILE="/run/etupr-black.pid"

# ---- helpers ----
have() { command -v "$1" >/dev/null 2>&1; }

# ---- 1) stop signage processes (safety) ----
/usr/bin/systemctl stop signage-browser.service >/dev/null 2>&1 || true
/usr/bin/systemctl stop signage-app.service     >/dev/null 2>&1 || true

# ---- 2) paint/cover screen with black (xterm fullscreen) ----
# If xterm is not installed, we still continue (other measures only)
if have xterm; then
  # kill previous black xterm if exists
  if [ -f "$PIDFILE" ]; then
    oldpid="$(cat "$PIDFILE" 2>/dev/null || true)"
    if [ -n "${oldpid:-}" ] && kill -0 "$oldpid" >/dev/null 2>&1; then
      kill "$oldpid" >/dev/null 2>&1 || true
      sleep 0.2
      kill -9 "$oldpid" >/dev/null 2>&1 || true
    fi
    rm -f "$PIDFILE" >/dev/null 2>&1 || true
  fi

  # start fullscreen black xterm on X(:0)
  # - hide cursor, keep running by tail -f /dev/null
  /usr/bin/sudo -u "$USER_NAME" \
    DISPLAY="$DISPLAY_NUM" XAUTHORITY="$XAUTH" \
    xterm -fullscreen -bg black -fg black -bd black -cr black -fa fixed -fs 1 \
      -e /bin/sh -lc 'printf "\033[?25l"; exec tail -f /dev/null' \
      >/dev/null 2>&1 &

  echo $! > "$PIDFILE"
fi

# ---- 3) reduce background services ----
/usr/bin/systemctl stop cups-browsed.service >/dev/null 2>&1 || true
/usr/bin/systemctl stop cups.service         >/dev/null 2>&1 || true
/usr/bin/systemctl stop ModemManager.service >/dev/null 2>&1 || true

# ---- 4) bluetooth: block radio + stop daemon (but may auto-restart via dbus) ----
/usr/sbin/rfkill block bluetooth >/dev/null 2>&1 || true
/usr/bin/systemctl stop bluetooth.service >/dev/null 2>&1 || true

# ---- 5) CPU governor -> powersave (best-effort) ----
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  [ -w "$f" ] && (echo powersave > "$f" 2>/dev/null || true) || true
done

exit 0