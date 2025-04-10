<%@ page contentType="text/html; charset=UTF-8" language="java" import="java.util.*, jspproject.*" %>
<%
  TimerMgr mgr = new TimerMgr();
  Vector<TimerBean> timerList = mgr.listTimer(0);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>타이머 탭</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/jspproject/css/TimerDesign.css" />
  <style>
    .timer-preview-box {
      width: 100%; height: 260px;
      position: relative; overflow: hidden;
      border-radius: 12px;
      box-shadow: 0 0 12px rgba(123, 44, 191, 0.6);
      background: white;
    }
  </style>
</head>
<body>
<div class="timer-container">
  <div class="timer-left">
    <div class="timer-tab">
      <button class="tab-btn" onclick="location.href='Background.jsp'">배경화면</button>
      <button class="tab-btn active">타이머</button>
    </div>

    <div class="timer-header">
      <div class="header-left"></div>
      <div class="header-right">
        <div class="filter-controls">
          <img id="sortAlpha" class="icontimerList" src="icon/아이콘_글자순_1.png" alt="글자순 정렬">
          <img id="sortLatest" class="icontimerList" src="icon/아이콘_오래된순_최신순_1.png" alt="최신/오래된 순">
          <input class="timer-search" type="text" placeholder="타이머 검색" />
          <img id="searchTimerBtn" class="icontimerList" src="icon/아이콘_검색_1.png" alt="검색">
        </div>
      </div>
    </div>

    <div class="timer-list" id="timerGrid"></div>
  </div>

  <div class="timer-right">
    <div class="timer-preview-wrapper">
      <div id="timerPreviewBox" class="timer-preview-box"></div>
    </div>
    <div id="selectedTimerLabel" class="timer-name-display"></div>
    <div class="timer-description">
      <textarea id="timerDescription" placeholder="타이머 설명을 입력하세요." readonly></textarea>
    </div>
    <div class="timer-cancel-button">
      <button class="btn-purple">타이머 취소</button>
    </div>
    <div class="timer-right-buttons">
      <button class="btn-purple" id="btnSave">적용</button>
    </div>
  </div>
</div>

<script>
const contextPath = "<%= request.getContextPath() %>";
const timerData = [
  <% for (int i = 0; i < timerList.size(); i++) {
    TimerBean t = timerList.get(i);
  %>
    {
      id: <%= t.getTimer_id() %>,
      label: "<%= t.getTimer_title().replace("\"", "\\\"") %>",
      description: "<%= t.getTimer_cnt() != null ? t.getTimer_cnt().replaceAll("\"", "\\\"").replaceAll("\r", "").replaceAll("\n", "\\n") : "" %>",
      thumb: contextPath + "/jspproject/img/<%= t.getTimer_img() %>",
      type: <%= t.getTimer_design() %>,
      session: <%= t.getTimer_session() %>,
      rest: <%= t.getTimer_break() %>
    }<%= (i < timerList.size() - 1) ? "," : "" %>
  <% } %>
];

let selectedTimer = null;
let currentSort = "latest";

function renderTimers(timers) {
  const grid = document.getElementById("timerGrid");
  grid.innerHTML = "";
  timers.forEach((timer) => {
    const div = document.createElement("div");
    div.className = "timer-button";
    const img = document.createElement("img");
    img.src = timer.thumb;
    img.alt = timer.label;
    img.className = "timer-thumb";
    div.appendChild(img);
    div.onclick = () => selectTimer(timer.type, timer.label, timer.description, timer.session, timer.rest);
    grid.appendChild(div);
  });
}

function selectTimer(type, label, description, session, rest) {
  selectedTimer = type;
  const previewBox = document.getElementById("timerPreviewBox");
  const labelBox = document.getElementById("selectedTimerLabel");
  const descriptionBox = document.getElementById("timerDescription");

  labelBox.textContent = label;
  descriptionBox.removeAttribute("readonly");
  descriptionBox.value = description || "";
  descriptionBox.setAttribute("readonly", true);
  previewBox.innerHTML = "";

  const iframe = document.createElement("iframe");
  iframe.src = "Timer" + type + ".jsp?session=" + session + "&break=" + rest + "&t=" + new Date().getTime();
  Object.assign(iframe.style, {
    width: "100%", height: "100%",
    border: "none", borderRadius: "12px"
  });
  previewBox.appendChild(iframe);
}

function getFilteredAndSortedTimers() {
  const keyword = document.querySelector(".timer-search").value.trim().toLowerCase();
  let filtered = timerData.filter(timer => timer.label.toLowerCase().includes(keyword));

  const basic = filtered.find(t => t.type === 1);
  const others = filtered.filter(t => t.type !== 1);

  if (currentSort === "latest") {
    others.sort((a, b) => b.id - a.id);
  } else if (currentSort === "oldest") {
    others.sort((a, b) => a.id - b.id);
  } else if (currentSort === "alpha") {
    others.sort((a, b) => a.label.localeCompare(b.label));
  }

  return basic ? [basic, ...others] : others;
}

function refreshTimers() {
  renderTimers(getFilteredAndSortedTimers());
  updateSortIcon();
}

function updateSortIcon() {
  const sortLatest = document.getElementById("sortLatest");
  if (currentSort === "latest") {
    sortLatest.alt = "최신순";
  } else if (currentSort === "oldest") {
    sortLatest.alt = "오래된순";
  } else {
    sortLatest.alt = "정렬 없음";
  }
}

document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("sortAlpha").addEventListener("click", () => {
    currentSort = currentSort === "alpha" ? "latest" : "alpha";
    refreshTimers();
  });

  document.getElementById("sortLatest").addEventListener("click", () => {
    if (currentSort === "latest") {
      currentSort = "oldest";
    } else if (currentSort === "oldest") {
      currentSort = "latest";
    } else {
      currentSort = "latest";
    }
    refreshTimers();
  });

  document.getElementById("searchTimerBtn").addEventListener("click", refreshTimers);
  document.querySelector(".timer-search").addEventListener("input", refreshTimers);
  document.querySelector(".timer-search").addEventListener("keypress", e => {
    if (e.key === "Enter") refreshTimers();
  });

  refreshTimers();
  if (timerData.length > 0) {
    const first = timerData.find(t => t.type === 1) || timerData[0];
    selectTimer(first.type, first.label, first.description, first.session, first.rest);
  }
});
</script>
</body>
</html>
