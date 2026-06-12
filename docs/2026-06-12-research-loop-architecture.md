# 2026-06-12 — research 루프 설계 (연구용 자율 루프 구조도)

- status: v1 (2026-06-12 — 초안 작성 → lab/ 이식 반영 → run 이력·문서
  지도 보강)
- 짝 문서: dev 루프 설계 `~/ralph/loop-design.md`
- 이식 계획: `../plans/2026-06-12-research-loop-lab-migration.md`
  (2026-06-12 — Stage 2 실행 위치를 `~/ralph`에서 `~/research/lab/`로 이동)
- 1차 사료(상세 결정·이론 인용):
  - `2026-06-11-research-loop-design.md` (주제 검증 파이프라인)
  - `2026-06-12-research-team-org-design.md` (견제·균형 + 세미나 트랙)
- 본 문서의 위치: ralph·research 두 루프는 형제이되 목표가 달라 분리
  기술함. 본 문서는 research(연구용) 쪽 구조도 — 위 두 1차 사료를 한 장으로
  합성하고, ralph와 갈리는 지점을 research 관점에서 적음. 결정의 세부
  근거·인용은 1차 사료에 있음.

## 1. 정체 — 무엇을 위한 루프인가

research 루프는 **연구주제를 실측으로 가르는 검증 엔진**임. 산출은 코드가
아니라 "이 연구주제는 진짜다/아니다"라는 근거임. ralph(dev 루프)를 가져와
연구 작업에 맞게 튜닝한 파생물이며(2026-06-11 배선, 2026-06-12 `lab/`
이식), 검증된 주제를 `~/dev`
실작업/제안서로 **승격**하는 것이 최종 목적임.

- 작동 단위 = 연구 질문 / 주제.
- 가동 단위 = run 1회 = 하룻밤 1주제.
- 설계 동기 = 검증 병목 해소. 가설 원천(전수 서베이 후보 + 백로그)은
  검증보다 빠르게 쌓이는데, 후보를 구현·측정으로 확정/기각하는 일은 전부
  사람 시간을 먹음. 기계로 옮길 수 있는 단계(포팅→빌드→측정→판정)를
  옮겨 "발굴" 루프의 처리량을 올리는 장치. **기각도 산출물**(재발굴 낭비
  방지).

## 2. 왜 ralph를 그대로 못 쓰나 — oracle 부재

ralph가 무인으로 끝까지 가는 힘은 기계 oracle임(`~/ralph/loop-design.md`
§2). 그런데 연구 작업의 본질적 판단 — "이 서베이 주장이 참인가", "이
주제가 팔 가치가 있는가", "novelty가 방어되는가" — 은 KAT으로 못 가름.
기계 판정자가 없음.

그래서 research 루프는 ralph의 골격을 물려받되 **oracle을 두 갈래로
대체**함:

- 기계가 가를 수 있는 부분(코드 실험·벤치)은 → **검증 엔진에 위탁**
  (파이프라인 Stage 2, §4). ralph에서 물려받은 골격이 `lab/` 샌드박스에서
  무인으로 돌고, 기계 oracle 판정을 그대로 씀.
- 기계가 못 가르는 부분(조사·실측·프로파일·노트)은 → **출처 규율**(순환
  인용 cross-check) + **성능 주장 전 baseline 실측**으로 대체. 판정은
  권고형(기각 권고/승격 권고)으로만 적고, **최종 확정은 사용자**.

이 oracle 부재가 ralph와 갈리는 단 하나의 축이고, research 루프의 구조가
"증거 수집은 자율, 판정·경계 통과는 사람 게이트"로 잡히는 이유임.

## 3. 두 겹 구조 — 작업 모드와 파이프라인

"research 루프"라는 말은 사실 두 가지를 가리킴. 둘을 구분해야 혼동이
풀림.

- **(a) research 자율 작업 모드** (`~/research/CLAUDE.md` Interaction
  mode): research 트리에서 가설→검증 사이클(조사·실측·프로파일·분석·노트
  작성·`research-topics` 갱신)을 멈춰 묻지 않고 진행하는 모드. "ralph
  규칙의 연구용 번안" — 기계 oracle 없이 §2의 대체 규율로 돎. 대화형
  세션에서 동작. 이 모드가 파이프라인의 Stage 1(가설 발굴·정련)과 Stage
  3(지식 환류)을 굴리는 엔진.
- **(b) 주제 검증 파이프라인**: 위 작업 모드가 검증 엔진(`lab/`)을
  Stage 2로 품어 무인 실험을 위탁하는 오케스트레이션(§4). 사람-게이트
  입구·출구가 무인 구간을 감싸는 바깥 껍데기.

즉 research는 검증 엔진을 **두 겹으로** 감쌈 — 엔진과 같은 종류의
루프(번안)이면서, 동시에 그 무인 구간을 사람-게이트 입구·출구로 감싸는
파이프라인.

## 4. 파이프라인 흐름 — 어떻게 작동하나

```
[research]            [research/lab/]        [research]          [dev]
가설 원천         →   무인 실험(샌드박스)  →  아침 리뷰        →  승격
                                                                (pull 모델)
─ Stage 1 입구 ─      ─ Stage 2 (무인) ─     ─ Stage 3 출구 ─    ─ 출구 너머 ─
 (사람 게이트)        (검증 엔진)            (사람 게이트)

Stage 1: research-topics·서베이에서 후보 1개 → spec 초안
         → red-team 심사 → 사용자 승인·동결 → status=running
Stage 2: lab/에서 spec 받아 /loop. 가설→oracle→journal→report. 무인.
         run 프로토콜: lab/CLAUDE.md. 쓰기는 lab/ 하위만 (샌드박스).
Stage 3: report 검토 → 지식 환류(노트) → status 확정
         (validated|rejected) → promote 권고면 승격 패널 → 승격
```

무인 자율성은 `lab/` 하위 트리에만 존재함 (2026-06-12 이식 — 종전
`~/ralph`. 과거 run은 `~/ralph/experiments/` 동결 아카이브). Stage 1·3과
dev 구간은 사람이 깨어 있는 대화형 세션.

### run의 하루 주기

- **저녁 (대화형, research)**: "다음 run 준비" 요청 → 후보 선정 → spec
  초안 → red-team 심사·작성자 서면 응답 (최대 2라운드) → 사용자
  승인·동결 → status=`running` → /loop 시작.
- **밤 (무인, lab/)**: pre-flight → iteration 반복 → report → 잔여 예산
  내 세미나 트랙. 기계 시간은 실측상 비병목 (§11) — 밤의 산출 품질은
  저녁의 spec 품질이 결정.
- **아침 (대화형, research)**: report 검토 → promote 권고면 승격 패널 →
  지식 환류(노트·index) → status 확정 → 승격(pull) → 세미나 후보 분류 →
  프로세스 회고 + ROI 장부 1줄.

## 5. ralph에서 가져온 것 + research 튜닝

research 루프가 ralph 골격에 얹은 연구용 튜닝 (2026-06-12
`lab/CLAUDE.md`로 이식 — 종전엔 ralph 차터에 배선되어 있었음, §10):

- **가설 원천 고정**: `research-topics.md`(논문화 지향 백로그) + 서베이
  마스터 테이블(적용 후보·실측 근거). spec에 출처 링크 의무.
- **Lakatos 주제 판정**: 새 예측을 계속 적중 = progressive(승격감),
  실패마다 ad-hoc 패치로 연명 = degenerating(기각감). 같은 "개선 확정
  1건"도 패치 0회와 5회는 다른 주제. → journal에 ad-hoc 패치 카운트,
  report에 "주제 판정" 섹션.
- **지식 환류**: run 요약을 `pqc-optimization/experiments/` 노트로,
  `index.md` 갱신. validated→승격, rejected→근거 기록.
- **승격 pull 모델**: 착수 문서를 `pqc-optimization/promotions/`에 두고
  `~/dev` 세션이 가져감. research는 dev에 직접 쓰지 않음(settings deny와
  정합).
- **status 컨벤션**: (무표기=백로그) → `running` → `validated` |
  `rejected`. `promoted`는 `validated`에서만.

## 6. 사람 게이트 — 자율 범위 밖

- **입구**: spec 승인·동결 (Stage 1). 승인 전까지 run 시작 금지.
- **출구**: status 확정·승격 (Stage 3). 무인 루프는 research/dev 경계를
  넘지 않음.
- **세미나 후보 분류**: 세미나가 낸 후보의 백로그 진입 (§7).
- 그 외 불변: 설계 문서·차터(CLAUDE.md류) 수정은 사람 동석 세션, Linear는
  read-only.

입구 게이트엔 승급 경로가 선언되어 있음 — 현행 1단계(run당 사람 승인) →
2단계(주제 풀 일괄 승인 후 자율 순환). 승급 가이드 기준은 spec 초안
3연속 구조 수정 없이 승인 + run 프로토콜 일탈 0회 + 칼리브레이션 누적
오차 비악화이며, 결정은 사용자 (1차 사료 6/11 설계 §안정화 승급 경로).

## 7. 견제·균형 + 세미나 트랙 (2026-06-12 팀 조직)

시니어 부재 2인 팀의 보완 장치. 독립적인 눈이 spec과 판정을 한 번 더 봄.
maker-checker / 블라인드 심사 골격(상세: `2026-06-12-research-team-org-
design.md`).

- **입구 red-team**(Stage 1): 작성자와 분리된 독립 subagent가 spec을 정적
  검토 + 읽기전용 검증(빌드 플래그 grep, 셋업 누락물, 지표 수식 정의,
  기각 조건 측정 가능성). blocker는 작성자가 서면 수용/반박.
- **출구 승격 패널**(Stage 3): promote 권고일 때만 3석 병렬 소집(방법론·
  재현성·도메인, 상호 비공개). 기각·보류면 패널 생략(비용은 비가역성에
  비례). 반대 의견은 다수결로 뭉개지 않고 원문 그대로 사용자에게.
- **세미나 트랙**(run 말미, 상한 2h): exploration/exploitation 분리.
  run의 발견을 발제 삼아 상반된 분야 렌즈 agent들이 분야 간 유추로 새 가설
  후보 생성. 산출은 `ideas/seminar-*.md`만 — 동결 spec·판정 불가침, 백로그
  진입은 아침 사용자 분류 게이트.
- **조직 ROI 장부**(`pqc-optimization/team-roi-ledger.md`): 가설에 요구하는
  규율을 조직 자신에게도 적용 — 일을 못 찾는 기구는 사전 선언 조건으로 격하.

## 8. 설계 근거 — 왜 이렇게 만들었나 (요약)

상세 인용은 1차 사료에. 핵심만:

- **Registered Reports 2단계 심사**: 입구=방법론만 심사, 출구=사전등록
  준수 심사. 사용자=PI 겸 편집장.
- **사전등록(동결 spec)**: HARKing 방지. ralph와 공유하는 규율.
- **발견/정당화 맥락 분리**: 탐험(세미나)은 무규율 허용, 정당화(검증
  엔진)는 규율. 세미나 산출은 판정에 못 닿고 백로그로만 흐름.
- **이중 루프 자가개선**: run 내 교정은 무인, 규칙 교정은 제안만(차터
  자기수정 금지 불변).

## 9. ralph 루프와의 관계 — 공통 골격, 갈리는 지점

- **공통 골격**: 루프 형태(spec→iterate→oracle→journal→report), oracle
  2-tier·종료 규칙, hard stop-lines, 이중 루프 자가개선 — ralph에서 그대로
  물려받음.
- **갈리는 단 하나의 축**: oracle 유무. ralph=기계 oracle 있음 → 판정까지
  무인, 산출이 증거물, spec 동결. research=기계 oracle 없음 → 증거 수집까지만
  무인, 판정은 권고형 + 사람 확정, 산출이 판단 재료, 사람 게이트가 입구·
  출구를 지킴.
- dev 루프 본체는 짝 문서 `~/ralph/loop-design.md` 참조.

## 10. 이식 상태 (2026-06-12)

wade 결정으로 자율 경계를 이동함 — research loop는 `~/research/lab/`에서,
ralph는 dev 전용으로. research 쪽 배선(lab/ 신설·차터 개정·본 문서 갱신)은
완료. 남은 사용자 액션: ralph 차터에서 research 튜닝 제거(ralph 밖 동석
세션), research settings에 lab 차터 잠금 추가, global zone 문구 보강(선택).
과거 run 3건은 `~/ralph/experiments/` 동결 아카이브 (worktree 메타데이터·
절대경로 링크 보존을 위해 이동하지 않음). 상세·체크리스트:
`../plans/2026-06-12-research-loop-lab-migration.md`.

## 11. run 이력과 실측 교훈 (2026-06-12 기준)

설계는 3 run의 실측으로 이미 한 차례 교정됨 — 6/12 팀 조직(red-team·
패널·세미나)은 머리로 만든 게 아니라 run #1·#2의 실패 신호에서 나옴.
설계 자신에게도 Lakatos 잣대를 적용하는 구조 (조직 ROI 장부).

| run | 주제 | 결과 | 비고 |
|---|---|---|---|
| #1 (6/11) | speculative-y-sampling | 4가설 전부 확정 (+4.25% ML-DSA-65 sign), promote 권고 → 항목 #9 `promoted` | ad-hoc 패치 0, 예산 8h 중 1.5h |
| #2 (6/11) | pqc-cert-compression | 3가설 확정 (CA dict 체인 ~52% 절감 등), promote 권고 → 출구 패널 파일럿 (1지지/2조건부/0반대) | 예산 8h 중 15분 |
| #3 (6/12) | speculative-y replication | run #1 재현 확정 (+3.20%, 동일 게이트 통과, 음성 대조군 PASS) | 입구 red-team 첫 적용 — blocker 2건 사전 차단, 첫 세미나 가동 |

누적 교훈 (report 자가 진단·ROI 장부에서):

- 실패는 과학이 아니라 spec·셋업 빈틈에서 발생 (stale 빌드 플래그,
  worktree 누락 파일, 지표 수식 미정의, 음성 대조군 부재) →
  pre-flight·red-team 신설의 실측 근거.
- 기계 시간은 비병목 (8h 예산 대비 실사용 15분~1.5h) → 루프 증설이
  아니라 입구(spec 품질) 강화가 맞는 투자.
- 재현 run 비용 ~45분 — 경계선·고부담 판정의 표준 옵션으로 쓸 만큼 쌈.
  재현 run은 패널 생략, 재현 실패 시만 소집 (run #3 합의).
- share형 지표의 예상 밴드는 A/B delta보다 넓게 잡을 것 (run #3
  칼리브레이션 교훈).

## 12. 문서 지도

| 무엇 | 어디 |
|---|---|
| 모드 선언 (자율 연구 존) | `~/research/CLAUDE.md` Interaction mode |
| run 프로토콜 (무인 규약, 영어 B1) | `~/research/lab/CLAUDE.md` |
| spec 템플릿 | `~/research/lab/TEMPLATE-spec.md` |
| 파이프라인 1차 사료 | `docs/specs/2026-06-11-research-loop-design.md` |
| 팀 조직 1차 사료 | `docs/specs/2026-06-12-research-team-org-design.md` |
| lab 이식 계획·잔여 사용자 액션 | `docs/plans/2026-06-12-research-loop-lab-migration.md` |
| 가설 백로그 + status 컨벤션 | `pqc-optimization/research-topics.md` |
| 조직 ROI 장부 | `pqc-optimization/team-roi-ledger.md` |
| 승격 착수 문서 (pull 모델) | `pqc-optimization/promotions/` |
| run 산출물 | `lab/<run>/` (과거 run: `~/ralph/experiments/`) |
| dev 루프 짝 문서 | `~/ralph/loop-design.md` |
| workspace 구조도 (공간 해부) | `docs/specs/2026-06-12-research-workspace-structure.md` |
