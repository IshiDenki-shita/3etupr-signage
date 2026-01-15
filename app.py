# Raspberry Pi上で動作するFlaskサーバー。外部APIへのGETリクエストも実行する

"""
インポート
"""
import time
from dataclasses import dataclass
import requests
from flask import Flask, render_template  # Flaskとテンプレート描画用の render_template をインポート
import threading
import json
import os

"""
グローバル変数・設定
"""
# データ取得先サーバーのURL
url_server = "http://162.43.43.163:8080/raspi/" # URLの階層構造は未定

# テンプレートファイル名
html_url_1 = "page1.html"
html_url_2 = "page2.html" # 津幡駅の時刻表を表示
html_url_3 = "page3.html" # 食堂の特別メニューを表示

# Flaskアプリケーションのインスタンスを作成
app = Flask(__name__)


"""
データ保持用クラス定義
"""
@dataclass
class DataStore():
    timetable: dict
    train: dict
    cafe: dict
data = DataStore({},{},{})
data_lock = threading.Lock() # スレッド間でのデータ競合を防ぐためのロック


"""
外部サーバーから定期的にデータを取得する関数
"""
def fetch_loop():
    while True:
        time.sleep(20)

        try:
            r = requests.get(url_server ,timeout=5)
            r.raise_for_status()
            data_dict = r.json() # JSONレスポンスを辞書型に変換
            print("サーバーへのアクセス成功")
            print(data_dict)

        except requests.RequestException as e:
            print("リクエストエラー発生")
            print(e)
            continue

        with data_lock:
            # キーが存在しない場合の安全策としてgetを使用
            data.timetable = data_dict.get("timetable", {})
            data.train = data_dict.get("train", {})
            data.cafe = data_dict.get("cafe", {})

"""
メイン関数
"""
def main():
    t = threading.Thread(target=fetch_loop, daemon=True) # データ取得ループを別スレッドで実行
    t.start()
    app.run(host="127.0.0.1", debug=True, port=8080)

"""
ルーティング設定
"""
@app.route("/")
def page1():
    return render_template(html_url_1)


@app.route("/page2")
def page2():
    # --- ロジックの統合 ---
    from datetime import datetime, timedelta

    OPERATIONAL_START_HOUR = 4

    # 内部ヘルパー関数
    def _get_upcoming_trains(timetable):
        """現在時刻以降の直近の列車データを抽出する"""
        if not timetable or "destination" not in timetable:
            return {"destination": {}}

        now = datetime.now()
        
        # --- 営業日の判定 ---
        if now.hour < OPERATIONAL_START_HOUR:
            operational_date = now.date() - timedelta(days=1)
        else:
            operational_date = now.date()

        result = {"destination": {}}

        for direction, trains in timetable["destination"].items():
            candidates = []
            
            for train in trains:
                t_hour = train['hour']
                
                # --- 列車の日付判定 ---
                is_next_day_in_schedule = (t_hour < OPERATIONAL_START_HOUR)
                
                if is_next_day_in_schedule:
                    train_date = operational_date + timedelta(days=1)
                else:
                    train_date = operational_date

                train_dt = datetime(
                    train_date.year, train_date.month, train_date.day,
                    t_hour, train['minute']
                )
                
                # 現在時刻との差分（秒）
                diff_seconds = (train_dt - now).total_seconds()
                
                # 表示対象: 発車時刻の5秒後まで
                if diff_seconds >= -5:
                    frontend_is_next_day = (train_dt.date() > now.date())

                    train_data = train.copy()
                    train_data['is_next_day'] = frontend_is_next_day
                    
                    candidates.append({
                        "data": train_data,
                        "diff": diff_seconds
                    })
            
            # 直近3件を取得
            result["destination"][direction] = [item["data"] for item in candidates[:3]]
            
        return result

    # --- 処理実行 ---
    # データの取得（ロック使用）
    with data_lock:
        current_timetable = data.train
    
    # データが空の場合にローカルのJSONを読み込む
    if not current_timetable:
        try:
            # dataフォルダ内のtimetable.jsonへのパス
            json_path = os.path.join(app.root_path, 'data', 'timetable.json')
            if os.path.exists(json_path):
                with open(json_path, 'r', encoding='utf-8') as f:
                    current_timetable = json.load(f)
                    print("Local timetable loaded.")
            else:
                print("Local timetable.json not found.")
        except Exception as e:
            print(f"Error loading local timetable: {e}")

    # 計算実行
    upcoming_data = _get_upcoming_trains(current_timetable)

    return render_template(html_url_2, train_data=upcoming_data)


@app.route("/page3")
def page3():
    return render_template(html_url_3)


if __name__ == "__main__":
    main()