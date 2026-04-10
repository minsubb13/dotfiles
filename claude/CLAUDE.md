# Global CLAUDE.md

## Code Style

- All code follows Chromium coding conventions across all languages
  - C/C++: CamelCase classes, snake_case variables/functions, trailing underscore for members (`member_`), 2-space indent, 80 column limit
  - Python: 2-space indent (not PEP 8's 4-space), 80 column limit
- Code comments in English

## Commit Style

- Chromium commit message convention
  - First line: `area: Capitalized verb summary` (e.g., `api: Add upload endpoint for .so library`)
  - Body: reason and context
  - No trailing period
  - Do NOT use conventional commits (feat:, fix:)

## Work Logs

- After completing each task, write a log to `docs/work-logs/`
  - Filename: `chunk{N}-task{N}-{description}.md`
  - Content: goal, actions taken, deviations from plan, impact on existing files

## Behavior

- On permission errors (sudo, etc.): stop and ask the user, do not change the plan
- On any anomaly (unexpected file state, dependency conflicts, test failures, etc.): stop and ask the user with situation explanation + options. Do not make autonomous decisions or apply workarounds
