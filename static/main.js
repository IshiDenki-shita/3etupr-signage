setInterval(() => {
  const now = new Date();
  const h = now.getHours();
  const m = now.getMinutes();
  const day = now.getDay(); // 0〜6 が返る　日曜日:0

  if (0 < day && day < 6) {
    //時間割　今は一時的に黒画面表示中
    if (window.location.pathname != "/black" && h == 8 && m < 50) {
      window.location.href = "/black";
    }

    //時刻表
    if (
      window.location.pathname != "/page2" &&
      (day == 1 || day == 3 || day == 5) &&
      ((h == 14 && 30 <= m) || (15 <= h && h < 19))
    ) {
      window.location.href = "/page2";
    }
    if (
      window.location.pathname != "/page2" &&
      (day == 2 || day == 4) &&
      ((h == 16 && 10 <= m) || (17 <= h && h < 19))
    ) {
      window.location.href = "/page2";
    }

    //食堂
    if (window.location.pathname != "/page3" && h == 12 && m < 60) {
      window.location.href = "/page3";
    }

    //黒
    if (
      window.location.pathname != "/black" &&
      ((h == 8 && 50 <= m) || (9 <= h && h < 12) || h == 13 || 19 <= h || h < 8)
    ) {
      window.location.href = "/black";
    }
    if (
      window.location.pathname != "/black" &&
      (day == 1 || day == 3 || day == 5) &&
      h == 14 &&
      m < 30
    ) {
      window.location.href = "/black";
    }
    if (
      window.location.pathname != "/black" &&
      (day == 2 || day == 4) &&
      ((14 <= h && h < 16) || (h == 16 && m < 10))
    ) {
      window.location.href = "/black";
    }
  }
}, 1000);
