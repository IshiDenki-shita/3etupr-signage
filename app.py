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
url_saitoVPS = "http://162.43.43.163:8080/api/v1/board" # URLの階層構造は未定

# html_url
html_url_1 = "page1.html" #時間割変更表示
html_url_2 = "page2.html"
html_url_3 = "page3.html" # 食堂の特別メニューを表示
html_url_black = "black.html"

# Flaskアプリケーションのインスタンスを作成
app = Flask(__name__)


"""
20秒に一回齋藤VPSにGETリクエスト送る
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
        time.sleep(20)

        try:
            r = requests.get(url_saitoVPS ,timeout=5)
            r.raise_for_status()
            data_dict = r.json() # JSONがdictになる
            print("\n\nサーバーへのアクセス成功!!\n\n")
            print(data_dict)

        except requests.RequestException as e:
            print("\n\nあかーん_リクエストでエラー発生!!!!!!!!!!\n\n")
            print(e)
            continue

        with data_lock:
            data.timetable = data_dict["timetable"]
            data.train = data_dict["train"]
            data.cafe = data_dict["cafe"]

"""
main関数
"""
def main():
    t = threading.Thread(target=fetch_loop, daemon=True) # 別スレッドでGETリクエストのループ
    t.start()
    app.run(host="127.0.0.1", debug=True, port=5000)

"""
ChromiumにHTMLを供給する
"""
# 担当：小原
@app.route("/")
def page1():
  main_timetable=[
    {
      "subjects": [
        {
          "period": 1,
          "subject": "英語講読I"
        },
        {
          "period": 2,
          "subject": "電気回路I"
        },
        {
          "period": 3,
          "subject": "総合数学"
        },
        {
          "period": 4,
          "subject": "国語III"
        }
      ],
      "date": "2026-01-26"
    },
    {
      "subjects": [
        {
          "period": 1,
          "subject": "応用物理I"
        },
        {
          "period": 2,
          "subject": "解析学II"
        },
        {
          "period": 3,
          "subject": "国語III"
        },
        {
          "period": 4,
          "subject": "電気電子工学基礎実験Ⅰ"
        }
      ],
      "date": "2026-01-30"
    }
  ]#仮
  for timetable in main_timetable:
      numders = re.findall(r"\d+", timetable["date"])
      timetable["date"] = f"{numders[1]}月{numders[2]}日"
      
  return render_template(html_url_1,main_timetable = main_timetable)


# 担当：中田と齋藤
@app.route("/page2")
def page2():
    return render_template(html_url_2)


# 担当：松本
@app.route("/page3")
def page3():
    return render_template(html_url_3)

# 黒い画面
@app.route("/black")
def black():
    return render_template(html_url_black)

if __name__ == "__main__":
    main()