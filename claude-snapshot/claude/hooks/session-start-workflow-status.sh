#!/usr/bin/env bash
# SessionStart hook: surface workflow state (Codex QA call count toward re-eval
# trigger, last session-log entry date) as additionalContext at session start.
set -euo pipefail

# Only fire for sessions under ~/dev (charter zone); silent elsewhere.
INPUT=$(cat || true)
CWD=$(jq -r '.cwd // empty' <<<"$INPUT" 2>/dev/null || true)
case "$CWD" in
  "$HOME/dev"|"$HOME/dev"/*) ;;
  *) exit 0 ;;
esac

METRICS="$HOME/.claude/projects/-home-remote3-dev/workflow-metrics"
CODEX_LOG="$METRICS/codex-calls.log"
SESSION_LOG="$METRICS/session-log.md"

if [[ -f "$CODEX_LOG" ]]; then
  CODEX_COUNT=$(wc -l < "$CODEX_LOG")
else
  CODEX_COUNT=0
fi

LAST_DATE="(no entries yet)"
if [[ -f "$SESSION_LOG" ]]; then
  LAST_LINE=$(grep -E '^## [0-9]{4}-[0-9]{2}-[0-9]{2}' "$SESSION_LOG" | tail -1 || true)
  if [[ -n "$LAST_LINE" ]]; then
    tmp="${LAST_LINE#\#\# }"
    LAST_DATE="${tmp%% |*}"
  fi
fi

MESSAGE="Workflow state — Codex QA calls since last re-eval: ${CODEX_COUNT}/20. Last session-log entry: ${LAST_DATE}. Per ~/dev/.claude/CLAUDE.md §4, append a session-log entry before ending any non-trivial session."

jq -nc --arg msg "$MESSAGE" \
  '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $msg}}'
