#!/bin/bash

# sudo実行の確認
if [ "$EUID" -ne 0 ]; then
    echo "$(date): ERROR - this script must be run with sudo"
    exit 1
fi

# ユーザーディレクトリの取得
if [ -n "$SUDO_USER" ]; then
    USER_DIR=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_DIR="$HOME"
fi
APP_DIR="${USER_DIR}/4etupr-signage"

# コマンド実行とログ出力の関数
execute() {
    local process_name="$1"
    shift
    local cmd="$@"
    
    echo "$(date): INFO - ${process_name} started"
    
    eval "$cmd" >/dev/null 2>&1 &
    local pid=$!
    
    while kill -0 $pid 2>/dev/null; do
        echo -n "."
        sleep 1
    done
    echo ""
    
    wait $pid
    local status=$?
    
    if [ $status -eq 0 ]; then
        echo "$(date): SUCCESS - ${process_name} completed"
    else
        echo "$(date): ERROR - ${process_name} failed"
        exit 1
    fi
}

# aptパッケージリストの更新
execute "apt update" "apt update"

# aptパッケージのアップグレード
execute "apt upgrade" "apt upgrade -y"

# wlr-randrのインストール
execute "wlr-randr installation" "apt install -y wlr-randr"

# リポジトリの同期（既存の場合は強制同期、新規の場合はクローン）
execute "repository sync" "if [ -d \"${APP_DIR}/.git\" ]; then cd \"${APP_DIR}\" && sudo -u $SUDO_USER git fetch origin && sudo -u $SUDO_USER git reset --hard origin/develop && sudo -u $SUDO_USER git clean -fd; else sudo -u $SUDO_USER git clone -b develop https://github.com/IshiDenki-shita/4etupr-signage.git \"${APP_DIR}\"; fi"

# 仮想環境の作成
execute "virtual environment creation" "sudo -u $SUDO_USER python3 -m venv ${APP_DIR}/.venv"

# 依存パッケージのインストール
execute "requirements installation" "sudo -u $SUDO_USER bash -c 'source ${APP_DIR}/.venv/bin/activate && pip install -r ${APP_DIR}/requirements.txt'"

# cron設定スクリプトの実行
execute "cron setup" "cd ${APP_DIR}/setup/tools && sudo -u $SUDO_USER bash ${APP_DIR}/setup/tools/setup_cron.sh"

echo "$(date): INFO - setup completed"