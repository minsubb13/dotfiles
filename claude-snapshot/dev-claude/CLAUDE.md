# ~/dev Workflow Charter

Applies to every project under `~/dev/`. Auto-loaded by Claude Code's ancestor walking when cwd is `~/dev/<project>/` or deeper. This file is the **primary workflow source**; global code-style rules live in `~/.claude/CLAUDE.md` and hook registrations live in `~/.claude/settings.json`. Memory holds only personal profile and platform-specific quirks.

## 0. Collaboration mode

- Interactive by default. Confirm approaches, surface decisions, never run fully autonomous modes (ralph, autopilot) without explicit user request.
- On any anomaly (unexpected file state, dependency conflict, test failure, permission error): stop and ask the user with situation + options. Never apply workarounds autonomously.

## 1. Scale gate

Propose scale as a draft at **Plan draft save** (before advisor ① call). User confirms or adjusts; record in the plan document. If scope drifts during Execute, escalate and re-agree.

| Tier | Criteria |
|---|---|
| Small | <200 LOC, 1–5 files, local function/component, style/refactor, lint fixes, docs, comments, dependency patch |
| Medium | ~500 LOC, multi-module, internal API contract changes, state-machine / concurrency work, dependency minor updates |
| Large | Sensitive path (declared in project CLAUDE.md), external API changes, architecture / schema / data migration, new deps or major updates, perf-critical path, 500+ LOC |

## 2. Five-stage workflow

### Research
- `Explore` subagent for codebase discovery.
- `scientist` for data analysis. `tracer` only as a subroutine when multi-hypothesis stalls systematic-debugging.

### Plan
- `superpowers:brainstorming` (if design space open) → `superpowers:writing-plans`.
- Save to `docs/superpowers/plans/YYYY-MM-DD-<feature>.md` (project) or `~/dev/plans/YYYY-MM-DD-<topic>.md` (cross-project meta-work).
- Small scope (per §1): plan doc not required. Design intent goes in spec or commit/PR prose.
- On save: propose scale → user confirms → advisor ① (medium/large) → propose Codex QA (medium/large) → user approves → freeze.

### Execute
- `superpowers:subagent-driven-development` default. `superpowers:executing-plans` for inline.
- `using-git-worktrees` for isolation when touching active branches.
- Per task: implementer → combined reviewer (fresh subagent — spec compliance + code quality in one pass).
- BLOCKED: `superpowers:systematic-debugging` → (multi-hypothesis) tracer subroutine → user.

### Review
- `superpowers:requesting-code-review` (final reviewer).
- Medium/large: advisor ② → Codex QA (read-only template at `~/dev/.claude/codex-qa-prompt.xml`, via `codex:codex-rescue` subagent, `task` mode, no `--write`).
- Codex QA dispatch: from the assistant, call `Agent` with `subagent_type="codex:codex-rescue"`. Avoid `Skill("codex:rescue")` — that is the user-facing slash command; assistant-side invocation forks and recurses (qcare-suite-v2 2026-05-07 incident: 742 self-spawned subagents over 1h33m, no Codex job ever started).
- Codex re-review cap: 1. Escalate to user if issues remain.

### Ship
- `superpowers:verification-before-completion`.
- `superpowers:finishing-a-development-branch`.
- Work log: `docs/work-logs/chunk{N}-task{N}-{description}.md` (project scope).
- Session-end log (see §4).

## 3. advisor / Codex / reviewer role matrix

| Checkpoint | When | Small | Medium | Large | Purpose |
|---|---|---|---|---|---|
| advisor ① | After Plan write, before Plan freeze | — | ✓ | ✓ | "Does the plan solve the stated goal?" |
| advisor ② | After final reviewer, before Codex QA | — | ✓ | ✓ | "Does implementation match intent?" |
| Codex QA | After advisor ② | — | ✓ | ✓ | SECURITY / HIDDEN_ASSUMPTION / ARCHITECTURE / BLIND_SPOT only |

**Codex role boundary (stated in prompt):** The four prior reviewers already covered spec compliance, style, merge readiness, and intent alignment. Codex focuses only on what they miss.

**Codex re-review cap:** 1 (so ≤2 total Codex calls per feature). After that, escalate to user — recurring findings are the class Claude cannot fix alone.

**Skip notice:** When skipping any checkpoint for small scale, emit one line:
> "Skipping advisor ② for small scale."
> "Skipping Codex QA: below scope gate (small: {file count}, {LOC}). Request explicitly if needed."

**Conflict resolution:** If advisor conflicts with first-hand evidence, push back with evidence or make a reconcile call. If advisor conflicts with user intent, surface to user immediately — never decide autonomously.

**Response handling for user:** When advisor or Codex returns findings that disagree with prior direction or propose significant changes, unpack each finding for the user before deciding. Required: list each point; translate agent jargon to user-accessible terms; connect to concrete examples from the user's transcript / work-logs / prior incidents; surface what the finding implies for the user's profile (experience, team, domain). Agent-to-agent summary is insufficient — user must understand the reasoning, not just the conclusion.

## 4. Session end logging

Before ending any session with plan writing, implementation, or review work, append to `~/.claude/projects/-home-remote3-dev/workflow-metrics/session-log.md`:

```
## YYYY-MM-DD | {session_id first 8 chars}
- Scale: small / medium / large
- Codex QA: invoked / skipped (reason)
- Codex findings applied: N/M
- Hook blocks: N (reasons if any)
- Notes: (anything notable)
```

Trivial sessions: skip silently. Trivial = (code change 0) AND (advisor 0) AND (codex 0) AND (no external system writes).

## 5. Hook boundary (Guard F)

**Allowed:** file existence checks, command execution (verify/lint/test/type-check), exit-code based blocking, notifications/logging on specific path changes.

**Forbidden:** code quality judgment, automatic code modification, deciding whether review is needed, **chaining LLM calls**.

**Principle:** Hooks block or log only. Never modify, never call LLMs.

## 6. Re-evaluation trigger (Guard G)

**Trigger:** 20 Codex QA calls accumulated in `~/.claude/projects/-home-remote3-dev/workflow-metrics/codex-calls.log`. Check via `wc -l` on that file; fire when ≥20. Reaching 20 is **organic accumulation**, not an alarm — if months pass without reaching it, that is a signal the workflow is light enough that meta-review is not urgent.

On fire:
- Read session-log entries accumulated since last re-evaluation.
- Audit per-guard metrics (call count, finding validity rate, skip distribution).
- Delete any guard showing no value across 3 consecutive cycles (throwaway principle).
- Tune thresholds as needed.
- Document the re-evaluation at `~/.claude/projects/-home-remote3-dev/workflow-metrics/review-YYYY-MM-DD.md`.
- Archive codex-calls.log as `codex-calls.YYYY-MM-DD.log.archive` and create an empty new log.

**Do not** read metrics docs during normal work — only when the trigger fires.

**Carry-forward to next re-evaluation (proposed 2026-05-18, deferred):**

- spec-primary workflow (plan-prose) — re-examine with cycle 2 data on which artifact the user actually re-opens during multi-session work (spec / plan / work-log).
- C2 verbatim/mechanical task reviewer skip — re-examine with cycle 2 data on per-task review signal capture and classification accuracy.
- Option-X maturity dimension — re-examine at cycle 3-4 once self-assessment vs guard-output calibration evidence exists.

## 7. Personal LLM Wiki Pointer

별도 디렉토리에 개인 LLM wiki가 있음: `~/wiki/`.

본 charter는 ~/dev/ 작업 흐름을 다루고, ~/wiki/는 자체 schema(`~/wiki/CLAUDE.md`)를 가짐. 두 트리는 의도적으로 분리 (charter 충돌 회피).

~/dev/에서 작업 중 사용자가 wiki 관련 요청(예: "이거 wiki에 정리", "wiki에서 X 찾아봐") 시: `~/wiki/CLAUDE.md`를 먼저 읽고 wiki schema에 따라 동작. 직접 cd하지 말고 절대경로로 파일 작업.

상세 design: `~/wiki/docs/2026-05-18-design.md`.
