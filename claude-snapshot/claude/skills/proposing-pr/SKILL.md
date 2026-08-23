---
name: proposing-pr
description: Use when user requests a PR proposal in Korean ("PR 제안해줘", "PR 만들어줘", "PR 생성해줘", "PR 올려줘" 등)
---

# Proposing a PR

사용자가 한국어로 PR 제안을 요청했을 때 적용. 기본은 title/description 텍스트만 출력하고 push/PR 생성은 사용자가 직접 수행. 사용자가 명시적으로 권한 위임("push와 PR 생성해줘", "draft로 올려줘" 등) 시에만 직접 실행.

## 출력 형식

- **Title**: 영어. 프로젝트 commit convention 따름 (Chromium 스타일이면 `area: Capitalized verb summary`).
- **Description**: 한국어 무미체(함/됨/그대로). 해요체 아님.

### TL;DR 섹션 (필수)

모든 PR description은 `## TL;DR`로 시작. 한 문단(또는 자연스러운 2~3 문장)으로 핵심. **문제(현상) → 채택한 해결 → 핵심 검증** 순서:
- 무엇이 문제·제약이었는지 (현상을 먼저)
- 그래서 무엇을 고쳤는지 / 어떤 방안을 채택했는지 (대안 있었다면 왜 이걸 골랐는지 한 줄)
- 어떤 핵심 검증(KAT/ctest baseline, 회귀 zero, 테스트 N pass 등)이 통과했는지

**TL;DR은 외부 독자 기준 self-contained여야 함 (필수).** 사전 컨텍스트가 0인 사람이 한눈에 이해하도록 평범한 말로 서술:
- 프로젝트 내부 전용 참조를 TL;DR에 쓰지 말 것 — 감사/이슈 finding 번호(`#1`, `#4` 등), 내부 티켓 ID, 우리끼리만 아는 약칭. (번호가 꼭 필요하면 `## Summary` 이하 깊은 섹션에 cross-reference로 남기고, TL;DR에선 그 번호가 가리키는 *내용*을 풀어 씀.)
- 코드 식별자(함수·변수·컬럼·심볼명)도 TL;DR에선 최소화. "`sessions.vendor` 컬럼 재사용" 대신 "세션을 생성한 vendor에 묶음"처럼 동작을 말로. 구현 디테일은 `## Summary`로.
- 자가 점검: "이 repo를 처음 보는 검토자가 TL;DR만 읽고 무슨 문제를 왜 어떻게 고쳤는지 아는가?" 아니오면 다시 씀.

### 추가 섹션 (스케일 기반)

~/dev charter §1 스케일 분류에 따라:

- **Small** (<200 LOC, 1–5 files): TL;DR 외엔 추가 prose 1단락이면 충분. 헤더 섹션 불필요.
- **Medium / Large**: TL;DR 다음에 헤더 섹션을 채워 검토자가 빠르게 scan 가능하게:
  - `## Summary` — TL;DR 확장. 채택 이유, 대안 비교, 부수적 결정.
  - `## Scope` — In Scope / Out of Scope (특히 다단계 작업의 일부일 때).
  - `## Diff stat` — `git diff --shortstat base..HEAD` 출력 + 상위 변경 영역 bullet.
  - `## Verification` — 빌드/테스트 명령 + Gate 결과 표(`| Gate | Result |`). 실제 돌린 명령과 숫자/단위 포함.
  - `## Doc updates` — 신규/수정 docs.
  - `## Scale` — small/medium/large 한 줄.
  - `## Dependency` — base가 다른 PR일 때 dependent PR임을 명시.
  - `## Notes` — deviation, follow-up, gate 가치 입증 등 검토자가 알면 좋은 컨텍스트.

### 일반 원칙

- 단락 수는 스케일에 맞춤. small은 짧게, large는 검토자에게 충분한 정보.
- 코드 diff을 그대로 풀어 쓰지 말 것. 의도와 핵심 변경점만.
- 같은 repo에서 직전 PR이 있으면 그 PR body 형식을 sample로 참고 (예: `gh pr view <N> --json body`).

## 기본 모드 — 절대 하지 말 것

사용자가 권한 위임 없이 "PR 제안해줘"만 요청한 경우:
- `git push` 실행
- `gh pr create` 실행 (`--draft` 등 모든 변형 포함)
- title을 한국어로 작성
- description을 영어로 작성
- 사용자가 시키지 않은 commit / amend / rebase 자동 수행

기본 모드에선 사용자가 자신의 손으로 push와 `gh pr create` 수행. skill 역할은 붙여넣을 텍스트 제공에서 멈춤.

## 권한 위임 모드

사용자가 명시적으로 "push와 PR 생성해줘", "PR 만들고 push까지", "draft로 올려줘" 같은 형태로 권한을 위임하면:

1. 본 skill로 PR body 텍스트 생성 (TL;DR + 스케일별 섹션)
2. `git push`로 브랜치 push (이미 push되어 있고 local HEAD = origin HEAD면 no-op)
3. `gh pr create --draft --base <적절한 base> --body-file <임시 파일>` (또는 `--body`로 직접)로 PR 생성
4. PR URL을 사용자에게 보고

Dependent PR(다른 미머지 PR 위에 쌓는 경우)은 base를 dependency 브랜치로 명시. dependency 관계가 불명확하면 PR 생성 전 사용자 확인.

이미 만든 PR의 title/body를 **수정**할 때: `gh pr edit`은 구버전 gh(예: 2.4.0)에서 deprecated "Projects classic" GraphQL 필드를 건드려 조용히 no-op로 실패함. 적용 안 됐으면 REST로 우회 — `gh api -X PATCH repos/<owner>/<repo>/pulls/<N> --input <json>` (`{"title":..,"body":..}`). 한글/마크다운 escape는 `python3 -c`로 JSON을 만들어 `--input`에 넘기면 안전. 수정 후 `gh api .../pulls/<N> -q .title` 등으로 실제 반영을 확인.

## Why

- 기본적으로 PR 생성 권한을 사용자가 유지. 자동 push/create는 명시 위임이 있을 때만 (memory `feedback_merge_authorization` 정합).
- title 영어 = GitHub 표준 관행. body 한국어 무미체 = 팀 커뮤니케이션 언어 + 문서류 컨벤션 (memory `feedback_tone_korean_polite`).
- TL;DR이 있어야 검토자가 풀 description 안 읽고도 PR 의도 파악 가능. medium/large에선 그 뒤 섹션이 scan 친화적.
- 스케일에 따라 양을 조절해야 small PR이 over-engineered look 안 되고, large PR이 정보 부족 안 됨.

## Example 1 — Small (기본 모드)

User: "이 작업 PR 제안해줘"

Response:

```
**Title:**
license-guard: Fix expiry race on system clock skew

**Description:**

## TL;DR

license-guard 만료 체크 race 수정. NTP 등으로 시스템 시계가 비교 직전에 갱신되면 직전까지 만료였던 라이선스가 한 번 통과되는 케이스 발견. monotonic clock 기준으로 교체. 시계 점프 시나리오 회귀 테스트 1건 추가, 기존 ctest 회귀 zero.

wall clock 보정 로직을 추가하는 안도 검토했으나 판정 경로를 단순하게 유지하는 쪽이 나아 monotonic 채택. `license_check_expiry()` 비교를 `clock_gettime(CLOCK_MONOTONIC)` 기반으로 변경.
```

이후 push와 `gh pr create`는 사용자가 직접 수행.

## Example 2 — Large (권한 위임 모드 + 헤더 섹션)

User: "push와 PR 모두 생성해줘. #71 참고해서 TL;DR 추가."

Response: TL;DR + `## Summary` + `## Scope` + `## Diff stat` + `## Verification` 표 + `## Doc updates` + `## Scale` + `## Dependency` + `## Notes` 포함한 body 작성 후 `git push` + `gh pr create --draft --base <...> --body-file ...` 실행, PR URL 사용자 보고.
