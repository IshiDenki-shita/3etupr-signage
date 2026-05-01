#!/bin/bash

ACTION=$1

# 実行ディレクトリのパスを取得
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# 引数に基づく処理
case "$ACTION" in
    on)
        echo "$(date): INFO - Executing wake-up procedures..."

        # ディスプレイの有効化
        bash "$BASE_DIR/display_controller.sh" off

        # CPUガバナーをondemandに変更
        for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            [ -w "$f" ] && echo ondemand > "$f" 2>/dev/null || true
        done
        echo "$(date): SUCCESS - CPU governor set to ondemand"

        # Bluetoothの有効化
        /usr/sbin/rfkill unblock bluetooth >/dev/null 2>&1 || true
        if /usr/bin/systemctl start bluetooth.service >/dev/null 2>&1; then
            echo "$(date): SUCCESS - Bluetooth enabled"
        else
            echo "$(date): FAILED - Could not enable Bluetooth"
        fi
        ;;
        
    off)
        echo "$(date): INFO - Executing sleep procedures..."

        # ディスプレイの無効化
        bash "$BASE_DIR/display_controller.sh" on

        # CPUガバナーをpowersaveに変更
        for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            [ -w "$f" ] && echo powersave > "$f" 2>/dev/null || true
        done
        echo "$(date): SUCCESS - CPU governor set to powersave"

        # Bluetoothの無効化
        /usr/sbin/rfkill block bluetooth >/dev/null 2>&1 || true
        if /usr/bin/systemctl stop bluetooth.service >/dev/null 2>&1; then
            echo "$(date): SUCCESS - Bluetooth disabled"
        else
            echo "$(date): FAILED - Could not disable Bluetooth"
        fi
        ;;
        
    *)
        # エラー時の使用法表示
        echo "Usage: $0 {on|off}"
        exit 1
        ;;
esac

exit 0