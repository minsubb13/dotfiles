# 레이아웃 타입 CSS 카탈로그

각 슬라이드에 적합한 레이아웃의 CSS를 여기서 복사하여 사용한다.

**전제 (SKILL.md B 섹션):**
- 색: 그린은 글자를 안 얹는 면(액센트 바·구분선·불릿)에만. 글자와 글자 얹는 면은 `--blue` → `--gray` → `--ink` 순환
- 타입: Display 52 / Title 33 / Lead 22 / Body 17 / Caption 14 — 이 다섯 값만
- 본문 `line-height 1.75`, 문단 `max-width 640px`, 좌정렬
- 격자: 좌우 기준선 x=35 / x=1245 고정, `gap: 24px`. **자식에 `max-width`를 걸지 말 것**
- 수직: 상단 고정. 모든 레이아웃 루트는 `width: 100%`
- 카드 테두리는 `--line` 중립, 색 구분은 상단 6px 바 하나로만

---

## 1. hero-cards — 2~3 대형 카드

**용도:** 오프닝 훅, 피처 쇼케이스, 핵심 포인트 강조

```css
.cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; width: 100%; }
.card {
  background: #fff;
  border: 1.5px solid var(--line);
  border-radius: 0;
  padding: 38px 28px 32px;
  position: relative;
  opacity: 0;
  transform: translateY(24px);
  animation: cardAppear 0.6s ease-out forwards;
}
.card:nth-child(1) { animation-delay: 0.1s; }
.card:nth-child(2) { animation-delay: 0.2s; }
.card:nth-child(3) { animation-delay: 0.3s; }
@keyframes cardAppear { to { opacity: 1; transform: translateY(0); } }
/* 상단 액센트 바 — 글자를 안 얹으므로 그린 고정 */
.card::before {
  content: ''; position: absolute; top: 0; left: 0; right: 0;
  height: 6px; background: var(--green);
}
/* 큰 숫자 강조 — 그린 금지, 블루/그레이/검정 순환 */
.card-stat { display: block; font-size: 52px; font-weight: 600; line-height: 1.1; color: var(--blue); margin-bottom: 16px; }
.card:nth-child(2) .card-stat { color: var(--gray); }
.card:nth-child(3) .card-stat { color: var(--ink); }
.card-text { font-size: 17px; font-weight: 500; line-height: 1.75; color: var(--ink); }
.card-label {
  display: inline-block; margin-top: 16px; padding: 6px 18px; border-radius: 999px;
  font-size: 14px; font-weight: 600; color: #fff; background: var(--blue);
}
.card:nth-child(2) .card-label { background: var(--gray); }
.card:nth-child(3) .card-label { background: var(--ink); }
```

**콘텐츠 밀도:** 2~3개 카드, 카드당 큰 값 + 2줄 텍스트 + 라벨
- 카드 내부는 **좌정렬**. 가운데 정렬하면 여러 줄의 시작점이 흐트러진다

---

## 2. roadmap — 타임라인/프로그레스 바

**용도:** 에피소드 개요, 시리즈 진행률

```css
.progress-section { width: 100%; }
.progress-label { font-size: 17px; font-weight: 500; line-height: 1.75; color: var(--ink-sub); margin-bottom: 24px; }
.progress-bar { display: grid; grid-auto-flow: column; grid-auto-columns: 1fr; gap: 8px; align-items: center; }
.progress-segment { height: 12px; border-radius: 0; }
.progress-segment.filled { background: var(--gray); }        /* 지나온 구간 */
.progress-segment.active { background: var(--green); height: 18px; }  /* 현재 — 글자 없는 면이라 그린 */
.progress-segment.empty  { background: var(--gray-fill); border: 1px solid var(--line); }
.progress-labels { display: grid; grid-auto-flow: column; grid-auto-columns: 1fr; gap: 8px; margin-top: 16px; }
.progress-labels span { font-size: 14px; font-weight: 600; color: var(--ink-sub); }
.progress-labels span.active-label { color: var(--ink); }
```

**콘텐츠 밀도:** 3~6개 세그먼트, 각 1줄 라벨
- 현재 구간은 그린과 높이로 구분. 글로우/애니메이션 금지

---

## 3. comparison-2col — 좌우 비교 박스

**용도:** vs 슬라이드, before/after, 도구 비교

```css
.comparison { width: 100%; }
.comparison-title { font-size: 22px; font-weight: 600; line-height: 1.4; color: var(--ink); margin-bottom: 24px; }
.comparison-row {
  display: grid; grid-template-columns: 1fr 56px 1fr;
  align-items: stretch; margin-bottom: 16px;
}
.comp-label { font-size: 14px; font-weight: 600; margin-bottom: 10px; }
.comp-old {
  background: #fff; border: 1.5px solid var(--line); border-radius: 0;
  padding: 20px 24px;
}
.comp-old .comp-label { color: var(--gray); }
.comp-arrow {
  display: flex; align-items: center; justify-content: center;
  font-size: 22px; font-weight: 600; color: var(--gray);
}
.comp-new {
  background: #fff; border: 1.5px solid var(--line); border-radius: 0;
  padding: 20px 24px; position: relative;
}
/* 결론 쪽만 상단 액센트 바로 표시 */
.comp-new::before {
  content: ''; position: absolute; top: 0; left: 0; right: 0;
  height: 6px; background: var(--green);
}
.comp-new .comp-label { color: var(--blue); }
.comp-body { font-size: 17px; font-weight: 500; line-height: 1.75; color: var(--ink-sub); }
.comp-new .comp-body { color: var(--ink); }
```

**콘텐츠 밀도:** 1~3개 비교 행
- 화살표 열은 `56px` 고정 — 좌우 박스 폭이 항상 같아진다

---

## 4. step-flow — 번호 붙은 세로 단계

**용도:** 설치 과정, 프로세스 설명

```css
.steps { display: flex; flex-direction: column; gap: 16px; width: 100%; }
.step {
  display: grid; grid-template-columns: 45px 1fr; gap: 24px; align-items: start;
  background: #fff; border: 1.5px solid var(--line); border-radius: 0;
  padding: 24px 28px;
  opacity: 0; transform: translateX(-16px);
  animation: stepIn 0.5s ease-out forwards;
}
.step:nth-child(1) { animation-delay: 0.1s; }
.step:nth-child(2) { animation-delay: 0.2s; }
.step:nth-child(3) { animation-delay: 0.3s; }
.step:nth-child(4) { animation-delay: 0.4s; }
@keyframes stepIn { to { opacity: 1; transform: translateX(0); } }
/* PPT 원형 뱃지 45px — 흰 글씨를 얹으므로 블루/그레이/검정 */
.step-num {
  width: 45px; height: 45px; border-radius: 50%;
  background: var(--blue); color: #fff;
  display: flex; align-items: center; justify-content: center;
  font-weight: 500; font-size: 22px;
}
.step:nth-child(2) .step-num { background: var(--gray); }
.step:nth-child(3) .step-num { background: var(--ink); }
.step:nth-child(4) .step-num { background: var(--blue); }
.step-title { font-size: 22px; font-weight: 600; line-height: 1.4; color: var(--ink); margin-bottom: 8px; }
.step-desc { font-size: 17px; font-weight: 500; line-height: 1.75; color: var(--ink-sub); max-width: 640px; }
```

**콘텐츠 밀도:** 3~5개 단계, 각 제목 + 1~2줄 설명
- `.step-desc`에 `max-width: 640px`이 걸려 있다. 카드 폭이 1211px이어도 문단은 640px에서 접힌다

---

## 5. diagram-box — 중앙 다이어그램 + 라벨

**용도:** 아키텍처, 보안 모델, 시스템 구조

```css
.diagram {
  width: 100%;
  background: #fff; border: 1.5px solid var(--line); border-radius: 0;
  padding: 32px 40px; text-align: center;
  margin-bottom: 24px;
}
.diagram-center {
  display: inline-block; padding: 12px 32px; border-radius: 0;
  background: var(--blue); color: #fff;      /* 글자를 얹으므로 블루 */
  font-size: 22px; font-weight: 600; margin-bottom: 24px;
}
.diagram-arrows { font-size: 22px; color: var(--gray); margin: 16px 0; }
.diagram-row { display: grid; grid-auto-flow: column; grid-auto-columns: 1fr; gap: 16px; }
.diagram-node {
  background: #fff; border: 1.5px solid var(--line); border-radius: 0;
  padding: 16px 20px; text-align: left; position: relative;
}
.diagram-node::before {
  content: ''; position: absolute; top: 0; left: 0; right: 0;
  height: 6px; background: var(--green);
}
.diagram-node-title { font-size: 22px; font-weight: 600; line-height: 1.4; color: var(--ink); margin-top: 8px; margin-bottom: 4px; }
.diagram-node-desc { font-size: 14px; font-weight: 600; color: var(--ink-sub); }
```

**콘텐츠 밀도:** 중앙 1개 + 하위 3~6개 노드

---

## 6. grid-2x2 — 2열/3열 기능 카드

**용도:** 기능 목록, 커넥터, 도구 소개

```css
.grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 24px; width: 100%; }
.grid.cols-3 { grid-template-columns: repeat(3, 1fr); }
.feature-card {
  background: #fff; border: 1.5px solid var(--line); border-radius: 0;
  padding: 0 0 24px; position: relative; overflow: hidden;
  transition: border-color 0.25s ease, transform 0.25s ease;
}
.feature-card:hover { transform: translateY(-3px); border-color: var(--gray); }
/* 헤더 밴드 — 흰 글씨를 얹으므로 블루/그레이/검정 순환 */
.feature-head {
  height: 36px; line-height: 36px; padding: 0 20px;
  background: var(--blue); color: #fff; font-size: 22px; font-weight: 600;
}
.feature-card:nth-child(2) .feature-head { background: var(--gray); }
.feature-card:nth-child(3) .feature-head { background: var(--ink); }
.feature-body { padding: 24px 20px 0; }
.feature-name { font-size: 22px; font-weight: 600; line-height: 1.4; color: var(--ink); margin-bottom: 8px; }
.feature-desc { font-size: 17px; font-weight: 500; line-height: 1.75; color: var(--ink-sub); max-width: 640px; }
.feature-key { font-size: 14px; font-weight: 600; color: var(--ink-sub); margin-bottom: 4px; }
```

**콘텐츠 밀도:** 3~6개 카드
- 헤더 밴드가 없는 단순 카드라면 밴드 대신 상단 6px 그린 바(`.n-card::before`)를 쓴다

---

## 7. three-stage-flow — 가로 3단계 진행

**용도:** 발전 과정, 워크플로우, 레벨업

```css
.flow { display: grid; grid-template-columns: 1fr 44px 1fr 44px 1fr; align-items: stretch; width: 100%; }
.flow-stage {
  padding: 0 0 26px; text-align: left;
  background: #fff; border: 1.5px solid var(--line); border-radius: 0;
  overflow: hidden;
}
.flow-arrow { display: flex; align-items: center; justify-content: center; font-size: 22px; color: var(--gray); }
/* PPT 셰브론 — 흰 글씨를 얹으므로 블루/그레이/검정 */
.flow-stage-num {
  display: block; height: 45px; line-height: 45px; padding: 0 20px 0 30px;
  background: var(--blue); color: #fff;
  font-size: 22px; font-weight: 600;
  clip-path: polygon(0 0, calc(100% - 18px) 0, 100% 50%, calc(100% - 18px) 100%, 0 100%, 18px 50%);
}
.flow-stage:nth-child(3) .flow-stage-num { background: var(--gray); }
.flow-stage:nth-child(5) .flow-stage-num { background: var(--ink); }
.flow-stage-body { padding: 24px 24px 0; }
.flow-stage-title { font-size: 22px; font-weight: 600; line-height: 1.4; color: var(--ink); margin-bottom: 12px; }
.flow-stage-desc { font-size: 17px; font-weight: 500; line-height: 1.75; color: var(--ink-sub); }
```

**콘텐츠 밀도:** 정확히 3단계
- `.flow` 자식은 stage/arrow/stage/arrow/stage 순서라 `nth-child`가 1·3·5가 된다
- 단계 안 텍스트는 **좌정렬** — 3단이면 열 폭이 이미 좁아 measure가 자연히 잡힌다

---

## 8. summary-grid — 3x2 요약 그리드 + 결론

**용도:** 마무리 슬라이드, 총정리

```css
.summary-grid {
  display: grid; grid-template-columns: repeat(3, 1fr);
  gap: 16px; width: 100%; margin-bottom: 24px;
}
.summary-card {
  background: #fff; border: 1.5px solid var(--line); border-radius: 0;
  padding: 26px 24px 22px; position: relative;
  opacity: 0; transform: translateY(16px);
  animation: cardIn 0.5s ease-out forwards;
}
@keyframes cardIn { to { opacity: 1; transform: translateY(0); } }
.summary-card:nth-child(1) { animation-delay: 0.1s; }
.summary-card:nth-child(2) { animation-delay: 0.2s; }
.summary-card:nth-child(3) { animation-delay: 0.3s; }
.summary-card:nth-child(4) { animation-delay: 0.4s; }
.summary-card:nth-child(5) { animation-delay: 0.5s; }
.summary-card:nth-child(6) { animation-delay: 0.6s; }
/* 액센트 바는 전부 그린 통일 — 카드끼리 색으로 구분하지 않는다 */
.summary-card::before {
  content: ''; position: absolute; top: 0; left: 0; right: 0; height: 6px;
  background: var(--green);
}
.card-name { font-size: 22px; font-weight: 600; line-height: 1.4; color: var(--ink); margin-bottom: 8px; }
.card-desc { font-size: 17px; font-weight: 500; line-height: 1.75; color: var(--ink-sub); }
.conclusion {
  padding: 24px 32px;
  background: var(--gray-fill); border: none; border-radius: 0;
  width: 100%;
}
.conclusion-line { font-size: 22px; font-weight: 600; line-height: 1.5; color: var(--ink); }
```

**콘텐츠 밀도:** 6개 요약 카드 + 결론 박스
- 액센트 바 색을 카드마다 돌리지 않는다. 6개가 다 다른 색이면 어느 것도 강조가 아니다
- 결론 문구는 `--ink` 단색. 그린 글자 금지 (2.12:1)
