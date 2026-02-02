echo "=== xterm ==="; pgrep -af xterm || echo "xterm none"
echo "=== signage ==="; systemctl is-active signage-app.service signage-browser.service signage-wakeup.service signage-sleep.service || true
echo "=== procs ==="; pgrep -af 'chromium|app\.py' || echo "no chromium/app.py"
echo "=== bluetooth ==="; systemctl is-active bluetooth.service || true; rfkill list bluetooth
echo "=== cups/mm ==="; systemctl is-active cups.service cups-browsed.service ModemManager.service || true
echo "=== governor ==="; cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null | sort | uniq -c || true