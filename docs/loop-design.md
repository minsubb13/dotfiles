# ralph 루프 설계 — 개발용 자율 실행 엔진

- status: v1 (2026-06-12 — 초안 작성 → 분리 이식 반영 → 계보·현황 보강)
- 언어: 사용자용 설계 문서라 한국어. loop-facing 규약(차터·spec·journal·
  report)은 영어 B1 — 루프가 읽는 규칙은 `CLAUDE.md`이지 본 문서가 아님.
- 짝 문서: research 루프 설계
  `~/research/docs/specs/2026-06-12-research-loop-architecture.md`
- 이식 계획: `~/research/docs/plans/2026-06-12-research-loop-lab-migration.md`
  (2026-06-12 — research run은 `~/research/lab/`로 이동, ralph는 dev 전용)
- 강제 규약: 차터 `~/ralph/CLAUDE.md`(잠김) +
  `~/ralph/.claude/settings.json`(permission deny)
- 본 문서의 위치: ralph·research 두 루프는 형제이되 목표가 달라 분리 기술함.
  본 문서는 그중 ralph(개발용) 쪽. 공통 골격은 양쪽에 다 나오되, 갈리는
  지점을 각자 자기 관점에서 적음.

## 1. 정체 — 무엇을 위한 루프인가

ralph 루프는 **개발 작업을 사람 개입 없이 끝까지 밀어붙이는 자율 실행
엔진**임. 가설 하나를 잡아 구현하고, 기계가 맞는지·빠른지 판정하고,
결과를 기록한 뒤 다음 가설로 넘어가는 사이클을 밤사이 무인으로 반복함.

- 작동 단위 = iteration (가설 1회 시도).
- 가동 단위 = 하룻밤 1 run.
- 원래 의도(설계 동기) = 빌드·테스트·측정으로 **완결까지 갈 수 있는**
  개발/최적화 작업을, 사람이 자는 동안 노는 compute로 무인 처리하는 것.
  사람 시간이 병목일 때 기계로 옮길 수 있는 단계를 옮기는 장치.

자율성은 이 트리(`~/ralph`) 안에만 존재함. 바깥으로 나가는 행위(merge,
release 등)는 permission 층에서 차단됨 (§5).

계보: 2026-06-01 pqc-research-pipeline 설계(문서 소실)가 무인 실험 존을
Phase 2로 게이트했고, ralph는 그 존의 별도 구현으로 만들어짐. 이후
2026-06-11 research 파이프라인이 ralph를 검증 엔진으로 차용했다가,
2026-06-12 분리 결정으로 research run은 `~/research/lab/`로 이식되고
ralph는 본래 의도인 dev 전용으로 복귀 (§8).

## 2. 왜 무인으로 끝까지 갈 수 있나 — 기계 oracle

ralph가 사람 없이 verdict까지 도달할 수 있는 단 하나의 이유는 **기계
oracle**의 존재임. 개발 작업은 "맞다/틀리다"와 "빠르다/느리다"를 사람의
판단 없이 기계가 직접 가를 수 있음 — 빌드가 깨지는가, KAT/round-trip이
통과하는가, 벤치 수치가 노이즈 위에서 개선됐는가. 이 판정자가 있기
때문에 루프가 자기 결과를 스스로 채점하고 다음 행동을 정할 수 있음.

이것이 research 루프와 갈리는 **근본 축**임. oracle이 있으면 판정까지
무인이 됨(ralph). oracle이 없으면 증거 수집까지만 무인이고 판정은 사람
몫이 됨(research). 나머지 차이는 전부 이 한 축에서 파생됨.

## 3. 루프 골격 — 어떻게 작동하나

```
[Stage 1] spec 승인·동결        (사람: 입구 게이트)
   │  experiments/YYYY-MM-DD-<topic>/spec.md
   ▼
[pre-flight] 빌드 커맨드·로컬 파일·환경 점검 → journal 기록
   │  blocker 실패 시 iteration 진입 전 조기 정지 + 진단 (예산 보호)
   ▼
┌─ 반복 (무인) ──────────────────────────────────┐
│  가설 선택 → worktree 구현 → oracle → journal append │
│     ▲                                    │       │
│     └──── 직전 진단을 읽고 다음 시도 ◀──────┘       │
└────────────────────────────────────────────────┘
   │  stop rule 발동 (§4)
   ▼
[report] 가설별 판정 + (현재는) 주제 판정 + 루프 자가 진단
```

- **spec 동결**: 승인된 spec은 변경 불가(pre-registration). 결과를 본 뒤
  가설·지표·임계를 바꾸는 것 금지. "기계 판정만 verdict로 인정" 조항의
  이론적 근거.
- **iteration**: 각 가설은 자기 branch/worktree에서 격리 구현됨. 한
  iteration의 산출은 journal 1 엔트리(가설, diff 요약, 수치, 판정, 다음
  행동).
- **실패 교정(single-loop)**: Tier 1 실패 엔트리는 원인 진단 + 다음 시도에
  바꿀 것을 구조화해 적고, 다음 iteration은 직전 진단을 먼저 읽고 시작함.
- **run 디렉토리 해부**: `experiments/YYYY-MM-DD-<topic>/` 한 폴더에
  spec.md · journal.md · report.md · data/(원시 수치) · 작업 worktree
  스크래치가 동거 — run 하나가 자기완결적 증거물 패키지 하나.
- **report 판정 4분류**: 가설별로 개선 확정 / 개선 없음 / Tier 1 실패 /
  미완 + go/no-go 추천. 루프는 머지하지 않음 — 추천만, 결정은 아침의
  사용자.

## 4. oracle 2-tier 와 종료 규칙

oracle은 spec에 선언된 기계 검사만 인정함. "좋아 보인다"는 verdict가
아님.

- **Tier 1 (정확성, 하드 게이트)**: build + KAT/round-trip + invariants.
  실패하면 그 변형을 성능 측정 없이 폐기. baseline이 Tier 1을 깨면 코드보다
  셋업(stale 빌드 플래그, 누락 로컬 파일)을 먼저 의심함.
- **Tier 2 (성능, 상대 개선)**: baseline을 같은 run에서 실측(옛 수치 재사용
  금지). run 시작 시 baseline을 n회 반복 측정해 노이즈 플로어 σ를 구하고,
  개선 인정 임계 = `max(spec 선언값, k×σ)`. 노이즈보다 작은 개선은 "개선
  없음".

종료 규칙(Stop-and-Ask를 대체):

- 같은 가설이 Tier 1을 3연속 실패 → 폐기, 다음 가설.
- 같은 실패 진단이 2연속 → 3회를 기다리지 않고 조기 폐기.
- iteration/시간 budget 소진 → 종료, report 작성.
- 가설 풀 소진 → 종료, report 작성.

## 5. hard stop-lines — 강제 경계

permission 층(`.claude/settings.json` deny)에서 강제됨. 우회 시도 금지.

- merge / PR merge / force-push / release / tag 생성 금지.
- `~/dev`·`~/.claude`(하네스) 수정 금지.
- 본 루프의 차터(`~/ralph/CLAUDE.md`)·`settings.json` 자기수정 금지
  (루프가 자기 규칙을 못 바꿈 — 자물쇠 자체 보호).
- normal push는 허용 — 실험 branch 백업·아침 리뷰용. 머지는 사용자만.

## 6. 설계 근거 — 왜 이렇게 만들었나

- **사전등록(동결 spec)** — 결과를 본 뒤 가설을 끼워 맞추는 HARKing 방지.
  "실패할 실질적 기회가 없던 테스트의 통과는 증거가 아님"(severe testing).
- **노이즈 플로어** — 단일 수치 비교는 측정 편향에 취약. 신뢰구간 없이
  "X% 빨라짐"을 주장하지 않게 임계를 노이즈에 묶음.
- **이중 루프 자가개선** — run 안의 실패 교정(single-loop)은 무인으로, 규칙
  자체의 교정(double-loop)은 루프가 *제안만* 하고 반영은 사람 게이트.
  파이프라인 자신도 개선 대상이라는 관찰의 구현.
- **A/B 경쟁가설** — 단일 가설 확증이 아니라 "어느 가설을 기각하는가"를
  가르는 구도. 기각 조건 없는 가설은 spec에 넣지 않음.

## 7. research 루프와의 관계 — 공통 골격, 갈리는 지점

- **공통 골격**: §3 루프 형태 + §4 oracle 2-tier·종료 규칙 + §5
  stop-lines + §6 자가개선. research 루프는 이 골격을 그대로 물려받음.
- **갈리는 단 하나의 축**: oracle 유무(§2). dev=기계 oracle 있음 →
  판정까지 무인, 산출이 증거물, spec 동결 가능. research=기계 oracle 없음
  → 증거 수집까지만 무인, 판정은 권고형 + 사람 확정, 산출이 판단 재료.
- 상세는 짝 문서(research 루프 설계) 참조.

## 8. 분리 이식 상태 (2026-06-12)

원래 ralph는 개발용 dev 루프로 의도됐으나, research 주제 검증
파이프라인(6/11·6/12 설계)이 자기 튜닝을 ralph **차터 안에** 배선하면서
두 루프가 한 파일에 섞여 있었음. wade 결정(2026-06-12)으로 자율 경계를
이동 — research loop는 `~/research/lab/`에서, ralph는 dev 전용으로.

이식 완료 (research 쪽):

- research 튜닝(가설 원천 고정, Lakatos 주제 판정·ad-hoc 패치 카운트,
  report 주제 판정 섹션, 세미나 트랙)은 `~/research/lab/CLAUDE.md`로
  이식됨. 입구 red-team·출구 승격 패널은 research 설계 문서 소관 그대로.
- 과거 research run 3건(speculative-y, cert-compression 등)은
  `~/ralph/experiments/`에 동결 아카이브로 잔류 (worktree 메타데이터·
  절대경로 링크 보존을 위해 이동하지 않음).
- 신규 research run은 lab/에서만 시작함.

남은 사용자 액션: `~/ralph/CLAUDE.md`에서 위 research 튜닝을 제거해
§1~§6 골격만 남기기 — 자기수정 금지 stop-line 때문에 ralph 밖에서 연
사용자 동석 세션 몫. 제거 목록·체크리스트:
`~/research/docs/plans/2026-06-12-research-loop-lab-migration.md`.
걷어내기 전까지 ralph 차터는 과도기적으로 research 문구를 포함함.

정직한 현황 한 줄: 순수 dev 작업 run은 아직 **0회**임. 골격(oracle·종료
규칙·spec 동결·pre-flight)은 research run 3회로 실전 검증됐지만
(speculative-y ×2, cert-compression — 전부 Tier 1 실패 0·ad-hoc 패치 0
으로 통과), dev 고유의 첫 run — 가설 원천을 spec이 자체 선언하고 dev용
템플릿을 쓰는 — 은 차터 strip 이후의 일. 첫 dev run에서 이 문서의
골격이 dev 작업에도 맞는지 자체 검증이 필요함.
