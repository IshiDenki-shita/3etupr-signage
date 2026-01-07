from flask import Flask, render_template #Flaskとテンプレート描画用の render_template をインポート

#html_url
html_url_1 = "page1.html"
html_url_2 = "page2.html"
html_url_3 = "page3.html"


app = Flask(__name__) #Flaskアプリケーションのインスタンスを作成

@app.route("/")
def page1():
    return render_template(html_url_1)

@app.route("/page2")
def page2():
    return render_template(html_url_2)

@app.route("/page3")
def page3():
    return render_template(html_url_3)

if __name__ == "__main__":
    app.run(debug=True)