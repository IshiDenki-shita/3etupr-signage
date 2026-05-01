#!/bin/bash

# ===== 設定 =====
OUTPUT="HDMI-A-1"
# ===============

ACTION=$1

# cron実行用のWayland環境変数
export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR=/run/user/$(id -u)

# wlr-randrコマンドの存在確認
if ! command -v wlr-randr &> /dev/null; then
    echo "$(date): ERROR - wlr-randr command not found."
    exit 1
fi

# 引数に基づく処理
case "$ACTION" in
    on)
        echo "Transitioning ${OUTPUT} to ON..."
        if wlr-randr --output "$OUTPUT" --on; then
            echo "$(date): SUCCESS - ${OUTPUT} turned ON"
        else
            echo "$(date): FAILED - Could not turn ON ${OUTPUT}"
            exit 1
        fi
        ;;
    off)
        echo "Transitioning ${OUTPUT} to OFF..."
        if wlr-randr --output "$OUTPUT" --off; then
            echo "$(date): SUCCESS - ${OUTPUT} turned OFF"
        else
            echo "$(date): FAILED - Could not turn OFF ${OUTPUT}"
            exit 1
        fi
        ;;
    *)
        # エラー時の使用法表示
        echo "Usage: $0 {on|off}"
        exit 1
        ;;
esac