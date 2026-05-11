# Global CLAUDE.md

## Behavior

### Stop and Ask

When in doubt, halt and surface to the user. Workarounds, silent assumptions, "I'll just pick one" — all forms of autonomous decision.

- On permission errors (sudo, etc.): stop and ask the user, do not change the plan
- On any anomaly (unexpected file state, dependency conflicts, test failures, etc.): stop and ask the user with situation explanation + options. Do not make autonomous decisions or apply workarounds
- Before implementing: state assumptions explicitly. If uncertain about intent, ask first — don't guess
- When multiple valid interpretations exist: present them all, don't pick silently
- When a simpler approach is possible: say so, push back when warranted

### Simplicity First

Default to the smallest version that solves the stated problem.

- If 200 lines could be 50, stop and rewrite
- Self-check before submitting: "Would a senior engineer call this overcomplicated?" If yes, simplify.

### Surgical Changes

- Don't improve adjacent code, comments, or formatting that isn't part of the task
- Match existing style, even if you'd write it differently
- If unrelated dead code exists, mention it — don't delete unless asked
- Remove only orphans (imports, vars, funcs) that YOUR changes created

Self-check: Every changed line should trace directly to the user's request.

## Conventions

### Code Style

- Languages with Chromium guidance: follow Chromium coding conventions
  - C/C++: CamelCase classes, snake_case variables/functions, trailing underscore for members (`member_`), 2-space indent, 80 column limit
  - Python: 2-space indent (not PEP 8's 4-space), 80 column limit
- Languages without Chromium guidance (Go, Rust, TypeScript, Shell, etc.): follow the Google Style Guide for that language
- Code comments in English

### Commit Style

- Chromium commit message convention
  - First line: `area: Capitalized verb summary` (e.g., `api: Add upload endpoint for .so library`)
  - Body: reason and context
  - No trailing period
  - Do NOT use conventional commits (feat:, fix:)

### Work Logs

After completing each task, write a log to `docs/work-logs/`.

- Filename: `YYYY-MM-DD-{description}.md`
- Format: Goal + ADR
  - **Goal**: what the task should achieve (the user's intent, not the title)
  - **Context**: prior state, constraints, what made a decision necessary
  - **Decision**: what was implemented, including the key choices and why they won over alternatives
  - **Consequences**: impact on existing files, follow-ups left open, tradeoffs accepted
