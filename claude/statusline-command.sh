#!/bin/sh
# Claude Code statusLine command
# Derived from ~/.bashrc PS1: \u@\h:\w
# Original: \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')
model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Build the PS1-style portion: user@host:dir in color
ps1_part=$(printf '\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[00m' \
  "$(whoami)" "$(hostname -s)" "$cwd")

# Build the context usage portion
if [ -n "$used" ]; then
  ctx_part=" [ctx: ${used}%]"
else
  ctx_part=""
fi

printf '%s  %s%s\n' "$ps1_part" "$model" "$ctx_part"
