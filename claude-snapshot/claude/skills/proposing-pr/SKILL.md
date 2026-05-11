---
name: proposing-pr
description: Use when user requests a PR proposal in Korean ("PR 제안해줘", "PR 만들어줘", "PR 생성해줘", "PR 올려줘" 등)
---

# Proposing a PR

사용자가 한국어로 PR 제안을 요청했을 때 적용. title과 description 텍스트만 출력하고, push나 PR 생성은 사용자가 직접 수행한다.

## 출력 형식

- **Title**: 영어로 작성. 프로젝트의 commit convention을 따른다 (Chromium 스타일이면 `area: Capitalized verb summary`).
- **Description**: 한국어로 작성. 아래 네 가지를 자연스러운 문장으로 엮어서 핵심만 간략히 서술:
  - 어떤 영역의 무슨 패치인지
  - 어떤 문제·제약이 있어서 손대게 됐는지
  - 어떤 방안을 채택했는지 (대안이 있었다면 왜 이걸 골랐는지 한 줄)
  - 실제로 어떻게 수정했는지
- 단락 1–3개로 충분. 작은 패치면 1단락, 큰 패치도 3단락을 넘기지 않음.
- `## Summary`, `## Changes`, `## Test Plan` 같은 boilerplate 섹션 금지. 헤더 없이 prose로 흐르게.
- 코드 diff을 그대로 풀어 쓰지 말 것. 의도와 핵심 변경점만.

## 절대 하지 말 것

- `git push` 실행
- `gh pr create` 실행 (`--draft` 등 모든 변형 포함)
- title을 한국어로 작성
- description을 영어로 작성
- 사용자가 시키지 않은 commit / amend / rebase 자동 수행

사용자가 자신의 손으로 push와 `gh pr create`를 수행한다. skill의 역할은 그 명령에 붙여넣을 텍스트를 제공하는 데서 멈춘다.

## Why

- 사용자가 PR 생성 권한을 본인에게 유지하고 싶어함. 자동 push/create를 원치 않음.
- title 영어는 GitHub 표준 관행. body 한국어는 팀 커뮤니케이션 언어.

## Example

User: "이 작업 PR 제안해줘"

Response:

```
**Title:**
license-guard: Fix expiry race on system clock skew

**Description:**
license-guard의 만료 체크 race 수정. NTP 등으로 시스템 시계가
비교 직전에 갱신되면 직전까지 만료였던 라이선스가 한 번 통과되는
케이스가 있었음.

시계 갱신과 무관하게 흐른 시간만으로 판정하도록 monotonic clock
기준으로 교체. wall clock 보정 로직을 추가하는 안도 검토했으나
판정 경로를 단순하게 유지하는 쪽이 나아 monotonic을 채택.
`license_check_expiry()`의 비교를 `clock_gettime(CLOCK_MONOTONIC)`
기반으로 바꾸고 시계 점프 시나리오 회귀 테스트 1건을 추가.
```

이후 push와 `gh pr create`는 사용자가 직접 수행.
