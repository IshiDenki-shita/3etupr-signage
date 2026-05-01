#!/bin/bash

# ===== 設定 =====
MONITOR_WIDTH=1920
MONITOR_HEIGHT=1080
PORT=8080
SERVER_START_COMMAND="python app.py"
MAX_WAIT_COUNT=20
WAIT_INTERVAL=0.5
BROWSER_URL="http://localhost:$PORT"
BROWSER_COMMAND="chromium --kiosk --window-size=$MONITOR_WIDTH,$MONITOR_HEIGHT --window-position=0,0 --app=$BROWSER_URL --password-store=basic"
# ===============

# cron実行時にapp.pyがあるディレクトリで実行されるように移動
cd "$(dirname "$0")/.." || exit 1

echo "$(date): INFO - Server starting..."

# サーバーをバックグラウンドで起動
$SERVER_START_COMMAND >/dev/null 2>&1 &

# サーバー起動完了を待機
COUNT=0
echo "$(date): INFO - Waiting for port $PORT to open..."

while [ $COUNT -lt $MAX_WAIT_COUNT ]; do
    if nc -z -w 1 localhost $PORT; then
        echo "$(date): SUCCESS - Server started on port $PORT"
        break
    fi

    sleep $WAIT_INTERVAL
    COUNT=$((COUNT + 1))
done

# タイムアウト確認
if [ $COUNT -ge $MAX_WAIT_COUNT ]; then
    echo "$(date): ERROR - Server start timeout"
    exit 1
fi

# ブラウザをバックグラウンドで起動
echo "$(date): INFO - Opening $BROWSER_URL with Chromium..."
$BROWSER_COMMAND >/dev/null 2>&1 &

echo "$(date): SUCCESS - Signage startup sequence completed"
exit 0