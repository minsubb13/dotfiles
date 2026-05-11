#!/bin/bash
# sync-claude.sh — Local Claude workflow assets → dotfiles snapshot (one-way).
#
# Run after editing ~/.claude/* or ~/dev/.claude/* to refresh the snapshot,
# then `git diff` and commit. The dotfiles repo is a snapshot store, not
# a sync target — the local install is never touched by this script.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
SNAP="$DOTFILES_DIR/claude-snapshot"

mkdir -p "$SNAP/claude" "$SNAP/dev-claude"

# Single files (machine-independent text or reference settings.json)
cp -L "$HOME/.claude/CLAUDE.md"     "$SNAP/claude/CLAUDE.md"
cp -L "$HOME/.claude/settings.json" "$SNAP/claude/settings.json"

# Directories — --delete prunes locally-removed files from snapshot
rsync -a --delete "$HOME/.claude/agents/" "$SNAP/claude/agents/"
rsync -a --delete "$HOME/.claude/hooks/"  "$SNAP/claude/hooks/"
rsync -a --delete "$HOME/.claude/skills/" "$SNAP/claude/skills/"

# ~/dev/.claude/ workflow charter assets
cp -L "$HOME/dev/.claude/CLAUDE.md"             "$SNAP/dev-claude/CLAUDE.md"
cp -L "$HOME/dev/.claude/codex-qa-prompt.xml"   "$SNAP/dev-claude/codex-qa-prompt.xml"

echo "Synced. Review with: cd $DOTFILES_DIR && git diff"
