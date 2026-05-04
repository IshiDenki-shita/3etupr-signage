#!/bin/bash

# ユーザーディレクトリを動的に取得（sudoでの実行も考慮）
if [ -n "$SUDO_USER" ]; then
    USER_DIR=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_DIR="$HOME"
fi
APP_DIR="${USER_DIR}/4etupr-signage"

# 実行とログ出力を共通化する関数
execute() {
    local success_msg="$1"
    shift
    
    if eval "$@" >/dev/null 2>&1; then
        echo "$(date): SUCCESS - ${success_msg}"
    else
        echo "$(date): ERROR - ${success_msg} failed"
        exit 1
    fi
}

# aptパッケージリストの更新
execute "apt update" "apt update"

# aptパッケージのアップグレード
execute "apt upgrade" "apt upgrade -y"

# wlr-randrのインストール
execute "wlr-randr installed" "apt install -y wlr-randr"

# リポジトリのクローン
execute "repository cloned" "cd ${USER_DIR} && git clone https://github.com/IshiDenki-shita/4etupr-signage.git"

# 仮想環境の作成
execute "virtual environment created" "cd ${APP_DIR} && python3 -m venv .venv"

# 依存パッケージのインストール
execute "requirements installed" "cd ${APP_DIR} && source .venv/bin/activate && pip install -r requirements.txt"

# cron設定スクリプトの実行
execute "cron setup executed" "${APP_DIR}/setup/setup_cron.sh"

echo "$(date): INFO - setup completed"