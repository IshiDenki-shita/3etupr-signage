#!/bin/bash

ACTION=$1

# 実行ディレクトリのパスを取得
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# 引数に基づく処理
case "$ACTION" in
    sleep)
        echo "$(date): INFO - Executing sleep procedures..."

        # ディスプレイの無効化
        bash "$BASE_DIR/display_controller.sh" off

        # CPUガバナーをpowersaveに変更
        for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            [ -w "$f" ] && echo powersave > "$f" 2>/dev/null || true
        done
        echo "$(date): SUCCESS - CPU governor set to powersave"
        ;;
        
    wake)
        echo "$(date): INFO - Executing wake-up procedures..."

        # ディスプレイの有効化
        bash "$BASE_DIR/display_controller.sh" on

        # CPUガバナーをondemandに変更
        for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            [ -w "$f" ] && echo ondemand > "$f" 2>/dev/null || true
        done
        echo "$(date): SUCCESS - CPU governor set to ondemand"
        ;;
        
    *)
        # エラー時の使用法表示
        echo "Usage: $0 {sleep|wake}"
        exit 1
        ;;
esac

exit 0