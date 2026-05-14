setInterval(() => {
  const now = new Date();

  const h = now.getHours();
  const m = now.getMinutes();
  const day = now.getDay(); // 日:0 月:1 火:2 水:3 木:4 金:5 土:6

  const currentMinutes = h * 60 + m;

  // 土日は常に黒画面
  if (day === 0 || day === 6) {
    if (window.location.pathname !== "/black") {
      window.location.href = "/black";
    }
    return;
  }

  // ---------- 前日〜7:00 黒 ----------
  if (currentMinutes < 7 * 60) {
    if (window.location.pathname !== "/black") {
      window.location.href = "/black";
    }
    return;
  }

  // ---------- 7:00〜8:50 時間割変更 ----------
  if (
    7 * 60 <= currentMinutes &&
    currentMinutes < 8 * 60 + 50
  ) {
    if (window.location.pathname !== "/timetable") {
      window.location.href = "/timetable";
    }
    return;
  }

  // ---------- 8:50〜12:00 黒 ----------
  if (
    8 * 60 + 50 <= currentMinutes &&
    currentMinutes < 12 * 60
  ) {
    if (window.location.pathname !== "/black") {
      window.location.href = "/black";
    }
    return;
  }

  // ---------- 12:00〜13:00 食堂特別メニュー ----------
  if (
    12 * 60 <= currentMinutes &&
    currentMinutes < 13 * 60
  ) {
    if (window.location.pathname !== "/cafe") {
      window.location.href = "/cafe";
    }
    return;
  }

  // 月水金
  if (day === 1 || day === 3 || day === 5) {

    // ---------- 13:00〜14:30 黒 ----------
    if (
      13 * 60 <= currentMinutes &&
      currentMinutes < 14 * 60 + 30
    ) {
      if (window.location.pathname !== "/black") {
        window.location.href = "/black";
      }
      return;
    }

    // ---------- 14:30〜19:00 電車 ----------
    if (
      14 * 60 + 30 <= currentMinutes &&
      currentMinutes < 19 * 60
    ) {
      if (window.location.pathname !== "/train") {
        window.location.href = "/train";
      }
      return;
    }
  }

  // 火木
  if (day === 2 || day === 4) {

    // ---------- 13:00〜16:10 黒 ----------
    if (
      13 * 60 <= currentMinutes &&
      currentMinutes < 16 * 60 + 10
    ) {
      if (window.location.pathname !== "/black") {
        window.location.href = "/black";
      }
      return;
    }

    // ---------- 16:10〜19:00 電車 ----------
    if (
      16 * 60 + 10 <= currentMinutes &&
      currentMinutes < 19 * 60
    ) {
      if (window.location.pathname !== "/train") {
        window.location.href = "/train";
      }
      return;
    }
  }

  // ---------- 19:00〜翌日 黒 ----------
  if (currentMinutes >= 19 * 60) {
    if (window.location.pathname !== "/black") {
      window.location.href = "/black";
    }
  }

}, 1000);