#!/bin/bash

# --- 設定 ---
MONITOR_WIDTH=1920
MONITOR_HEIGHT=1080
PORT=8080
SERVER_START_COMMAND="python app.py"
MAX_WAIT_TIME=10
WAIT_INTERVAL=0.5
BROWSER_URL="http://localhost:$PORT"
BROWSER_COMMAND="chromium --kiosk --window-size=$MONITOR_WIDTH,$MONITOR_HEIGHT --window-position=0,0 --app=BROWSER_URL --password-store=basic"
# -----------

echo "--- server starting ---"

# サーバーをバックグラウンドで起動し、PIDを取得
$SERVER_START_COMMAND &
SERVER_PID=$!

# スクリプト終了時にサーバープロセスを確実に停止する設定
trap "kill $SERVER_PID 2>/dev/null; echo -e '\n--- server shutdown completed ---'" EXIT

# --- サーバー起動完了を待機（ポーリング） ---
ELAPSED_TIME=0
echo "waiting for port $PORT to open..."

while [ $ELAPSED_TIME -lt $MAX_WAIT_TIME ]; do
    # netcat (nc) コマンドでポートが開いているかチェック
    # -z: スキャンモード (データ送信なし)
    # -w 1: タイムアウトを1秒に設定
    if nc -z -w 1 localhost $PORT; then
        echo "server started"
        break
    fi

    # 待機
    sleep $WAIT_INTERVAL
    ELAPSED_TIME=$(echo "$ELAPSED_TIME + $WAIT_INTERVAL" | bc)
    
    # 待機中に '.' を表示して進捗を示す
    echo -n "."
done

# --- タイムアウト確認 ---
if [ $ELAPSED_TIME -ge $MAX_WAIT_TIME ]; then
    echo -e "\ERROR: timeout"
    # サーバーを停止してスクリプトを終了
    exit 1
fi

# --- ブラウザ起動 ---
echo "opening $BROWSER_URL with chromium..."
$BROWSER_COMMAND $BROWSER_URL

# スクリプトが終了するまで待機（ブラウザを閉じると終了）
wait