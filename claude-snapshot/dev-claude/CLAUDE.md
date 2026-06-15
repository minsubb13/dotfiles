# ~/dev Workflow Charter

Applies to every project under `~/dev/`. Auto-loaded by Claude Code's ancestor walking when cwd is `~/dev/<project>/` or deeper. This file is the **primary workflow source**; global code-style rules, user profile, and communication style live in `~/.claude/CLAUDE.md`; hook registrations live in `~/.claude/settings.json`. Auto-memory is keyed to the session cwd (no ancestor walking), so each project's memory holds only facts specific to that project.

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
- Work log: `docs/work-logs/YYYY-MM-DD-{description}.md` (project scope).
- Session-end log (see §4).

## 3. advisor / Codex / reviewer role matrix

| Checkpoint | When | Small | Medium | Large | Purpose |
|---|---|---|---|---|---|
| advisor ① | After Plan write, before Plan freeze | — | ✓ | ✓ | "Does the plan solve the stated goal?" |
| advisor ② | After final reviewer, before Codex QA | — | ✓ | ✓ | "Does implementation match intent?" |
| Codex QA | After advisor ① (plan) and after advisor ② (impl) | — | ✓ | ✓ | SECURITY / HIDDEN_ASSUMPTION / ARCHITECTURE / BLIND_SPOT only |

**Codex role boundary (stated in prompt):** The four prior reviewers already covered spec compliance, style, merge readiness, and intent alignment. Codex focuses only on what they miss.

**Codex re-review cap:** 1 per QA checkpoint. After that, escalate to user — recurring findings are the class Claude cannot fix alone.

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

**Boundary interpretation (user adjudication 2026-05-18):** continuation of the same mission/session (e.g. auto-resume across a quota window) is not LLM chaining; chaining means a hook triggering a *new* LLM task.

## 6. Re-evaluation trigger (Guard G)

**Trigger:** 20 Codex QA calls accumulated in `~/.claude/projects/-home-remote3-dev/workflow-metrics/codex-calls.log`. Check via `wc -l` on that file; fire when ≥20. Reaching 20 is **organic accumulation**, not an alarm — if months pass without reaching it, that is a signal the workflow is light enough that meta-review is not urgent.

On fire:
- Read session-log entries accumulated since last re-evaluation.
- Audit per-guard metrics (call count, finding validity rate, skip distribution).
- Dormant guards: surface keep-vs-retire to the user with removal as the recommended default — don't mechanically wait out 3 cycles when an existing rule (§0–§5) already covers it (2026-06-02 decision).
- Tune thresholds as needed.
- Document the re-evaluation at `~/.claude/projects/-home-remote3-dev/workflow-metrics/review-YYYY-MM-DD.md`.
- Archive codex-calls.log as `codex-calls.YYYY-MM-DD.log.archive` and create an empty new log.

**Do not** read metrics docs during normal work — only when the trigger fires.

**Carry-forward to next re-evaluation (proposed 2026-05-18, deferred):**

- spec-primary workflow (plan-prose) — re-examine with cycle 2 data on which artifact the user actually re-opens during multi-session work (spec / plan / work-log).
- C2 verbatim/mechanical task reviewer skip — re-examine with cycle 2 data on per-task review signal capture and classification accuracy.
- Option-X maturity dimension — re-examine at cycle 3-4 once self-assessment vs guard-output calibration evidence exists.

## 7. Personal LLM Wiki Pointer

A personal LLM wiki lives in a separate directory: `~/wiki/`.

This charter governs the `~/dev/` workflow; `~/wiki/` has its own schema (`~/wiki/CLAUDE.md`). The two trees are intentionally separate (to avoid charter conflicts).

When working in `~/dev/` and the user makes a wiki-related request (e.g. "이거 wiki에 정리", "wiki에서 X 찾아봐"): read `~/wiki/CLAUDE.md` first and act per the wiki schema. Do not `cd` into it — operate on files via absolute paths.

Detailed design: `~/wiki/docs/2026-05-18-design.md`.
