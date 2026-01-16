let h, m, day;

setInterval(() => {
  const now = new Date();
  h = now.getHours();
  m = now.getMinutes();
  day = now.getDay(); // 0〜6 が返る　日曜日:0

  //時間割
  if (window.location.pathname != "/" && h == 8 && m == 0) {
    window.location.href = "/";
  }

  //時刻表
  if (
    window.location.pathname != "/page2" &&
    h == 14 &&
    m == 30 &&
    (day == 1 || day == 3 || day == 5)
  ) {
    window.location.href = "/page2";
  }
  if (
    window.location.pathname != "/page2" &&
    h == 14 &&
    m == 30 &&
    (day == 2 || day == 4)
  ) {
    window.location.href = "/page2";
  }

  //食堂
  if (window.location.pathname != "/page3" && h == 12 && m == 0) {
    window.location.href = "/page3";
  }

  //黒
  if (
    window.location.pathname != "/black" &&
    ((h == 8 && m == 50) || (h == 13 && m == 0) || (h == 19 && m == 0))
  ) {
    window.location.href = "/black";
  }
}, 1000);
