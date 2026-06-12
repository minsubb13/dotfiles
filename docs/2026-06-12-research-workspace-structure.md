# 2026-06-12 — research workspace 구조 (디렉토리 해부)

- status: v1 (2026-06-12 작성)
- 짝 문서: 루프가 "흐름"이라면 본 문서는 "공간" —
  `2026-06-12-research-loop-architecture.md` (research 루프),
  `~/ralph/loop-design.md` (dev 루프)
- 1차 사료: `2026-06-11-research-loop-design.md`,
  `2026-06-12-research-team-org-design.md`,
  `../plans/2026-06-12-research-loop-lab-migration.md`

## 1. 정체 — 무엇을 위한 공간인가

`~/research`는 연구 분야 전반을 다루는 workspace임. 산출물은 코드가
아니라 **연구 판단 재료** — 노트, 실측, 주제 status, 승격 문서. 분야
하나당 하위 디렉토리 하나이며, 루트는 정책만 들고 지식은 각 분야가 듦.

2026-06-11 전환으로 자율 연구 존 — 가설→검증 사이클(조사·실측·노트)은
멈춰 묻지 않고 진행하되, 판정 확정과 경계 통과(승격·차터 수정)는 사용자
게이트. 2026-06-12 이식으로 무인 실행 샌드박스(`lab/`)를 품게 됨.

## 2. 디렉토리 해부

```
~/research/
├ CLAUDE.md                존 차터 — 모드 선언 + 파이프라인 개요 (잠김)
├ .claude/settings.json    보편 하드라인 deny (잠김)
├ .git/                    workspace 전체가 git repo — 자율 편집의
│                          리뷰·복구 수단 (문서 변경은 커밋 의무)
├ docs/                    workspace 운영 문서 (한국어 무미체)
│  ├ specs/                설계 문서 — 루프·팀 조직·구조도 (설계 사고의 1차 사료)
│  ├ plans/                실행 계획 — 배선·이식 (집행 절차 + 잔여 액션)
│  └ work-logs/            세션별 작업 기록 (Goal + ADR 형식)
├ lab/                     ★ 무인 루프 샌드박스 (2026-06-12 신설)
│  ├ CLAUDE.md             run 프로토콜 (영어 B1, 잠금 예정)
│  ├ TEMPLATE-spec.md      run spec 템플릿
│  └ YYYY-MM-DD-<topic>/   run 디렉토리 = 자기완결 증거물 패키지
│                          (spec·journal·report·data·review·ideas·worktree)
├ pqc-optimization/        분야 1 — 확정 PQC 전방위 최적화 연구 (wiki형)
│  ├ CLAUDE.md             분야 운영 매뉴얼 (정책만, lazy-load 지시)
│  ├ index.md              허브 — 카테고리별 페이지 카탈로그 (진입점)
│  ├ map.md                전방위 지형도 (orientation anchor)
│  ├ notes/                주제별 공부 노트 (1주제 1파일, frontmatter+[[링크]])
│  ├ research-topics.md    가설 백로그 + 파이프라인 status 컨벤션
│  ├ decisions/            ADR (방향 선택)
│  ├ experiments/          적용·PoC 결과 — 사람 작업 + run 환류 노트
│  ├ promotions/           승격 착수 문서 (pull 모델 — ~/dev 세션이 가져감)
│  ├ team-roi-ledger.md    조직(red-team·패널·세미나) ROI 장부
│  └ proposal-*.md         제안서 작업본 (연구의 산출물)
└ qcare-suite-v2-research/ 연구용 코드 worktree
                           (branch research/optimization-survey, 미머지 —
                           lab run worktree의 원천)
```

## 3. 조직 원리 — 왜 이렇게 생겼나

- **분야 단위 모듈화.** 루트 차터는 모드·파이프라인 같은 횡단 정책만.
  지식과 운영 컨벤션은 분야 디렉토리의 CLAUDE.md가 듦 — 분야가 늘어도
  루트가 비대해지지 않는 구조.
- **wiki + lazy-load.** 분야 안에서는 전체 폴더를 훑지 않음 — `index.md`
  에서 후보 페이지를 식별하고 그 페이지만 읽음. 페이지는 frontmatter +
  `[[링크]]`, basename은 ~/research 전체에서 globally unique (날짜
  prefix가 자연 방지).
- **사람/기계 경계 = 신뢰 모델.** `lab/`은 무인 루프가 쓰는 유일한 곳,
  나머지 전부는 사람이 큐레이션. 루프의 journal·report는 "증거물"이고,
  그것을 노트·status로 빚는 일은 아침 리뷰의 사람 몫 — 그래야 "research
  노트는 사람이 검수한 지식"이라는 신뢰가 유지됨.
- **이중 잠금.** settings deny는 보편 하드라인(merge·force-push·release,
  ~/dev·~/.claude 수정, 차터 자기수정)만 — 세션 종류를 구분 못 하므로.
  "무인 루프는 lab/만 쓴다"는 행동 규칙은 차터 prose로 강제.
- **git 커밋 의무.** 자율 존에서 사람 부재 중 일어난 편집의 리뷰·복구
  수단. 문서 변경은 커밋으로 남김.
- **언어 이원화.** loop-facing(lab 차터·spec·journal·report)은 영어
  CEFR B1 — 루프(및 이종 모델 좌석)의 오독 최소화. research 쪽
  위키·정책·설계 문서는 한국어 무미체.

## 4. 가설의 일생 — 흐름이 공간을 관통하는 길

```
research-topics.md (백로그 항목)
  → lab/<run>/spec.md (저녁: 동결·status=running)
  → lab/<run>/journal·report·data (밤: 무인 증거 수집)
  → pqc-optimization/experiments/ 노트 + index.md (아침: 지식 환류)
  → research-topics.md status 확정 (validated | rejected)
  → [validated 중 사용자 승인 시] promotions/ 착수 문서
  → ~/dev 세션이 pull → dev 차터 Plan 단계
```

기각된 가설도 같은 길의 산출물 — 근거가 research-topics에 남아 재발굴
낭비를 막음. 세미나 산 후보는 `lab/<run>/ideas/` → 아침 분류 →
research-topics 진입 (`origin: seminar` 표기) → 이후 다른 후보와 동일
취급.

문서의 결: `docs/specs/`(설계 사고) → `docs/plans/`(집행 절차) →
`docs/work-logs/`(세션 기록) → 분야 wiki(지식). 설계 변경은 specs에
개정 표기로 누적 — 문서 계보가 곧 의사결정 이력.

## 5. 경계와 이웃

- **~/dev** — 승격의 목적지. research에서 직접 쓰지 않음 (settings
  deny + pull 모델). 사람이 깨어 있는 dev 세션이 promotions/를 가져감.
- **~/ralph** — dev 전용 자율 루프 (2026-06-12 분리). 과거 research run
  3건의 동결 아카이브(`~/ralph/experiments/`)를 보관 — worktree
  메타데이터·절대경로 링크 보존을 위해 이동하지 않음.
- **Linear** — read-only. 이슈 등록은 사용자의 명시 요청 시만.
- **~/wiki** — 개인 위키 (도메인 참고). 컨벤션의 원류 (frontmatter·
  [[링크]]는 ~/wiki 재사용).
