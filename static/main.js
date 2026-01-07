if ((window.location.pathname == "/")) {
  // 5秒後に page2 に移動
  setTimeout(() => {
    window.location.href = "/page2";
  }, 5000);
}

if ((window.location.pathname == "/page2")) {
  // 5秒後に page3 に移動
  setTimeout(() => {
    window.location.href = "/page3";
  }, 5000);
}

if ((window.location.pathname == "/page3")) {
  // 5秒後に page1 に移動
  setTimeout(() => {
    window.location.href = "/";
  }, 5000);
}