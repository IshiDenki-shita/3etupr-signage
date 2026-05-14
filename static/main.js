const schedule = {
  1: [ // 月
    { path: "/timetable", duration: 30000 },
    { path: "/train", duration: 30000 },
    { path: "/cafe", duration: 20000 },
    { path: "/black", duration: 10000 },
  ],

  2: [ // 火
    { path: "/timetable", duration: 40000 },
    { path: "/train", duration: 30000 },
    { path: "/cafe", duration: 20000 },
    { path: "/black", duration: 10000 },
  ],

  3: [ // 水
    { path: "/timetable", duration: 30000 },
    { path: "/train", duration: 40000 },
    { path: "/cafe", duration: 20000 },
    { path: "/black", duration: 10000 },
  ],

  4: [ // 木
    { path: "/timetable", duration: 40000 },
    { path: "/train", duration: 30000 },
    { path: "/cafe", duration: 20000 },
    { path: "/black", duration: 10000 },
  ],

  5: [ // 金
    { path: "/timetable", duration: 30000 },
    { path: "/train", duration: 50000 },
    { path: "/cafe", duration: 20000 },
    { path: "/black", duration: 10000 },
  ],
};

function startRotation() {
  const day = new Date().getDay();

  // 土日は黒画面固定
  if (!(day in schedule)) {
    if (window.location.pathname !== "/black") {
      window.location.href = "/black";
    }
    return;
  }

  const pages = schedule[day];

  let currentIndex = pages.findIndex(
    (page) => page.path === window.location.pathname
  );

  if (currentIndex === -1) {
    currentIndex = 0;
    window.location.href = pages[0].path;
    return;
  }

  const currentPage = pages[currentIndex];

  setTimeout(() => {
    const nextIndex = (currentIndex + 1) % pages.length;
    window.location.href = pages[nextIndex].path;
  }, currentPage.duration);
}

startRotation();