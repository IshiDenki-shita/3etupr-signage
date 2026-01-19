# ラズパイの中で動作するflaskサーバー。GETリクエストも行う

"""
色々なインポート
"""
import time
from dataclasses import dataclass
import requests
from flask import Flask, render_template  # Flaskとテンプレート描画用の render_template をインポート
import threading
import re

"""
色々なグローバル変数
"""
# GETしに行く齋藤VPSのURL
url_saitoVPS = "http://100.71.1.106:8080/api/v1/board" 

# html_url
html_url_1 = "page1.html" #時間割変更表示
html_url_2 = "page2.html"
html_url_3 = "page3.html" # 食堂の特別メニューを表示
html_url_black = "black.html"

# Flaskアプリケーションのインスタンスを作成
app = Flask(__name__)


"""
データを格納するデータクラス 担当：松本
担当：松本
"""
@dataclass
class data_GET():
    timetable: dict
    train: dict
    cafe: dict
data = data_GET({},{},{})
data_lock = threading.Lock() # これで値の使用中に値を変更できなくなる


"""
齋藤VPSにGETし続ける関数（ゆくゆくはタイムスケジュールで）
"""
def fetch_loop():
    # 真っ当なやり方思いつかんだ
    while True:

        try:
            r = requests.get(url_saitoVPS ,timeout=5)
            r.raise_for_status()
            data_dict = r.json() # JSONがdictになる
            print("\n\nサーバーへのアクセス成功!!\n\nGETしたデータ")
            print(data_dict)

        except requests.RequestException as e:
            print("\n\nあかーん_リクエストでエラー発生!!!!!!!!!!\n\n")
            print(e)
            continue
        except ValueError as e:
            print("\n\nあかーん_GETしたJSONがおかしい!!!!!!!!!!\n\n")
            print(e)
            continue

        with data_lock:
            data.timetable = data_dict.get("timetable", {})
            data.train = data_dict.get("train", {})
            data.cafe = data_dict.get("cafe", {})

        time.sleep(300)


"""
main関数
"""
def main():
    t = threading.Thread(target=fetch_loop, daemon=True) # 別スレッドでGETリクエストのループ
    t.start()
    app.run(host="127.0.0.1", debug=True, port=8080)

"""
ChromiumにHTMLを供給する
"""
# 担当：小原
@app.route("/")
def page1():
  if data.timetable["main_timetable"]:
    main_timetable  = data.timetable["main_timetable"]
    for timetable in main_timetable:
        numders = re.findall(r"\d+", timetable["date"])
        print("DEBUG timetable['date'] =", timetable["date"])
        print("DEBUG numders =", numders)

        timetable["date"] = f"{numders[1]}月{numders[2]}日"
      
  return render_template(html_url_1,main_timetable = main_timetable)


# 担当：中田と齋藤
@app.route("/page2")
def page2():
    from datetime import datetime, timedelta
    import json
    import os

    OPERATIONAL_START_HOUR = 4

    def _get_upcoming_trains(timetable):
        """現在時刻以降の直近の列車データを抽出する"""
        if not timetable or "destination" not in timetable:
            return {"destination": {}}

        now = datetime.now()
        
        if now.hour < OPERATIONAL_START_HOUR:
            operational_date = now.date() - timedelta(days=1)
        else:
            operational_date = now.date()

        result = {"destination": {}}

        for direction, trains in timetable["destination"].items():
            candidates = []
            
            for train in trains:
                t_hour = train['hour']
                
                is_next_day_in_schedule = (t_hour < OPERATIONAL_START_HOUR)
                
                if is_next_day_in_schedule:
                    train_date = operational_date + timedelta(days=1)
                else:
                    train_date = operational_date

                train_dt = datetime(
                    train_date.year, train_date.month, train_date.day,
                    t_hour, train['minute']
                )
                
                diff_seconds = (train_dt - now).total_seconds()
                
                if diff_seconds >= -5:
                    frontend_is_next_day = (train_dt.date() > now.date())

                    train_data = train.copy()
                    train_data['is_next_day'] = frontend_is_next_day
                    
                    candidates.append({
                        "data": train_data,
                        "diff": diff_seconds
                    })
            
            result["destination"][direction] = [item["data"] for item in candidates[:3]]
            
        return result


    current_timetable = {}
    try:
        json_path = os.path.join(app.root_path, 'data', 'timetable.json')
        if os.path.exists(json_path):
            with open(json_path, 'r', encoding='utf-8') as f:
                current_timetable = json.load(f)
        else:
            print("Local timetable.json not found.")
    except Exception as e:
        print(f"Error loading local timetable: {e}")

    upcoming_data = _get_upcoming_trains(current_timetable)

    return render_template(html_url_2, train_data=upcoming_data)


# 担当：松本
@app.route("/page3")
def page3():
    with data_lock:  # 代入中に値が変更されないようロック
        cafe_data = data.cafe

    # 今日の日付（JST）を "YYYY-MM-DD" 形式で作る
    from datetime import datetime, timezone, timedelta

    JST = timezone(timedelta(hours=9))
    today_str = datetime.now(JST).date().isoformat()

    # メニュー一覧から、date が今日のものだけ抽出（先頭10文字だけ比較して日付フォーマットに柔軟）
    menus = cafe_data.get("menus", [])
    today_menus = [
        m for m in menus if (str(m.get("date", ""))[:10].replace("/", "-") == today_str)
    ]

    # 今日の特別メニューが無ければ、メッセージを1行だけ渡す
    if not today_menus:
        today_menus = [
            {
                "name": "今日は特別メニューなし",
                "price": 0,
                "date": today_str,
            }
        ]

    return render_template(html_url_3, menu_row=today_menus)


# 黒い画面
@app.route("/black")
def black():
    return render_template(html_url_black)

if __name__ == "__main__":
    main()