# Index.html 전체 템플릿

index.html은 네비게이션 바 없이 허브 페이지로 동작. `navigateTo()` 함수는 카드 링크용으로 포함.

슬라이드와 달리 1280×720 고정 캔버스가 아니라 **세로 스크롤 허브 페이지**다. PPT 템플릿의 "인덱스" 레이아웃 어휘(그린 타이틀 + 좌측 번호 + 우하단 로고)를 웹 그리드로 옮긴 형태.

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=1280">
<title>{{프레젠테이션 제목}} — 비주얼 자료</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/pretendard@1.3.9/dist/web/static/pretendard.css">
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
:root {
  --bg:        #FFFFFF;
  --ink:       #000000;
  --ink-sub:   #323C46;
  --green:     #94C11F;
  --blue:      #0F5087;
  --gray:      #505050;
  --gray-fill: #F2F2F2;
  --line:      #D8E2E7;
}
body {
  background: var(--bg);
  font-family: 'Pretendard', 'Noto Sans KR', sans-serif;
  color: var(--ink);
  min-height: 100vh;
  display: flex;
  justify-content: center;
  padding: 60px 0 80px;
}
.container { width: 1280px; padding: 0 80px; position: relative; }
.index-logo { position: absolute; right: 80px; top: 4px; width: 106px; height: 27px; }
.page-title {
  font-size: 42px; font-weight: 600; color: var(--ink);
  letter-spacing: -0.02em; margin-bottom: 8px;
}
.page-subtitle {
  font-size: 17px; font-weight: 500; line-height: 1.75; color: var(--ink-sub); margin-bottom: 48px;
}

/* Sections */
.section { margin-bottom: 32px; }
.section-header {
  font-size: 22px; font-weight: 600; line-height: 1.4; padding: 12px 20px;
  background: var(--gray-fill); color: var(--ink);
  border-left: 6px solid var(--green);   /* 글자 안 얹는 면 → 그린 통일 */
  margin-bottom: 16px;
  display: flex; align-items: center; gap: 12px;
}
.num-range {
  display: inline-block; font-size: 14px; font-weight: 600; color: #fff;
  padding: 4px 14px; border-radius: 999px;
}

/* Grid */
.grid {
  display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px;
}
.card {
  display: flex; flex-direction: column; gap: 8px; padding: 20px;
  background: #fff; border: 1.5px solid var(--line);
  border-radius: 0; text-decoration: none;
  transition: border-color 0.25s ease, transform 0.25s ease;
}
.card:hover { transform: translateY(-3px); }
.card .card-num { font-size: 33px; font-weight: 600; line-height: 1.1; }
.card .card-title { font-size: 17px; font-weight: 600; line-height: 1.4; color: var(--ink); }
.card .card-file { font-size: 14px; color: var(--ink-sub); font-family: 'Courier New', monospace; }

/* === 섹션별 색상 — 글자 자리라 그린을 빼고 블루/그레이/검정 3색 순환 === */
/* 인트로 (블루) */
.section-intro .num-range { background: var(--blue); }
.section-intro .card:hover { border-color: var(--blue); }
.section-intro .card .card-num { color: var(--blue); }

/* 섹션 1 (그레이) */
.section-1 .num-range { background: var(--gray); }
.section-1 .card:hover { border-color: var(--gray); }
.section-1 .card .card-num { color: var(--gray); }

/* 섹션 2 (검정) */
.section-2 .num-range { background: var(--ink); }
.section-2 .card:hover { border-color: var(--ink); }
.section-2 .card .card-num { color: var(--ink); }

/* 섹션 3 (블루, 순환) */
.section-3 .num-range { background: var(--blue); }
.section-3 .card:hover { border-color: var(--blue); }
.section-3 .card .card-num { color: var(--blue); }

/* 섹션 4 (그레이, 순환) */
.section-4 .num-range { background: var(--gray); }
.section-4 .card:hover { border-color: var(--gray); }
.section-4 .card .card-num { color: var(--gray); }

/* 섹션 5 (검정, 순환) */
.section-5 .num-range { background: var(--ink); }
.section-5 .card:hover { border-color: var(--ink); }
.section-5 .card .card-num { color: var(--ink); }

/* 아웃트로 (블루) */
.section-outro .num-range { background: var(--blue); }
.section-outro .card:hover { border-color: var(--blue); }
.section-outro .card .card-num { color: var(--blue); }

/* 페이지 전환 애니메이션 */
body { opacity: 0; animation: fadeIn 0.4s ease forwards; }
body.fade-out { animation: fadeOut 0.3s ease forwards; }
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: translateY(0); }
}
@keyframes fadeOut {
  from { opacity: 1; transform: translateY(0); }
  to { opacity: 0; transform: translateY(-12px); }
}
</style>
</head>
<body>
<div class="container">
  <img class="index-logo" src="norma-logo.png" alt="NORMA">
  <h1 class="page-title">{{프레젠테이션 제목}}</h1>
  <p class="page-subtitle">전체 {{TOTAL}}개 슬라이드 · 클릭하여 개별 페이지로 이동</p>

  <!-- 섹션별로 반복 -->
  <div class="section section-intro">
    <div class="section-header"><span class="num-range">{{범위}}</span> {{섹션명}}</div>
    <div class="grid">
      <a class="card" href="{{파일명}}" onclick="event.preventDefault(); navigateTo(this.href)">
        <span class="card-num">{{NN}}</span>
        <span class="card-title">{{슬라이드 제목}}</span>
        <span class="card-file">{{파일명}}</span>
      </a>
      <!-- 카드 반복 -->
    </div>
  </div>
  <!-- 섹션 반복 -->
</div>

<script>
function navigateTo(url) {
  document.body.classList.add('fade-out');
  setTimeout(function() { window.location.href = url; }, 300);
}
</script>
</body>
</html>
```

**핵심 규칙:**
- index.html에는 nav 바 없음
- `navigateTo()`는 카드 클릭 전환용
- 섹션별 색상 코딩은 블루/그레이/검정 3색 순환 (section-intro, section-1~5, section-outro). **그린은 글자·뱃지에 쓰지 않는다** (대비 2.12:1)
- 섹션 헤더 좌측 6px 바만 그린 통일 — 글자를 얹지 않는 면이므로
- 4열 그리드 카드 레이아웃, 각진 모서리 + 1.5px `--line` 보더
- 타이틀은 좌정렬 `--ink` 단색 — 그라디언트 금지
- 글자 크기는 42 / 33 / 22 / 17 / 14 다섯 값만
- `norma-logo.png`는 슬라이드와 같은 폴더에 있어야 한다
