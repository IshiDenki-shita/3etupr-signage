#!/bin/bash

# ジョブリストファイルのパス (親ディレクトリのjobs.txt)
JOBS_FILE="../jobs.txt"

# 設定ファイルの存在確認
if [ ! -f "$JOBS_FILE" ]; then
  echo "$(date): ERROR - Jobs file not found: $JOBS_FILE"
  exit 1
fi

# ファイルから有効な行のみを読み込み (空行とコメントを除外)
mapfile -t JOBS < <(grep -v '^\s*$' "$JOBS_FILE" | grep -v '^\s*#')

# 現在の設定を取得 (エラー出力は抑制)
CURRENT_CRON=$(crontab -l 2>/dev/null)
NEW_CRON="$CURRENT_CRON"
ADDED_COUNT=0

echo "$(date): INFO - Starting cron job synchronization from $JOBS_FILE"

# 各ジョブの重複確認と追加
for JOB in "${JOBS[@]}"; do
  # 前後の余計な空白を削除
  JOB=$(echo "$JOB" | xargs)
  [ -z "$JOB" ] && continue

  # コマンド部分のみを抽出して重複チェック (6フィールド目以降)
  CMD=$(echo "$JOB" | cut -d' ' -f6-)

  if echo "$CURRENT_CRON" | grep -Fq "$CMD"; then
    echo "$(date): INFO - Skipping: Job already exists: $CMD"
  else
    # 設定リストに追加
    NEW_CRON=$(echo -e "${NEW_CRON}\n${JOB}")
    ADDED_COUNT=$((ADDED_COUNT + 1))
    echo "$(date): SUCCESS - Job marked for addition: $CMD"
  fi
done

# 更新が必要な場合のみ実行
if [ $ADDED_COUNT -gt 0 ]; then
  # 空行を除去してcrontabを更新 (標準出力とエラーを抑制)
  if echo "$NEW_CRON" | grep -v '^$' | crontab - >/dev/null 2>&1; then
    echo "$(date): SUCCESS - Successfully updated crontab with $ADDED_COUNT new jobs"
  else
    echo "$(date): ERROR - Failed to update crontab"
    exit 1
  fi
else
  echo "$(date): INFO - No changes required for crontab"
fi

echo "$(date): INFO - Cron setup process completed"