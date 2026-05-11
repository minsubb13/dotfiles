# Dotfiles

Personal development environment configuration for macOS and Linux.

# Features

- **Shell**: Zsh with Oh My Zsh
- **Theme**: Powerlevel10k
- **Plugin Manager**: Antigen
- **Tools**: autojump, fzf, bat

## Prerequisites

Before installation, ensure you have the following installed:

- git
- vim
- zsh
- curl

## Installation

1. Clone this repository:

    ```bash
    git clone https://github.com/minsubb13/dotfiles.git
    cd dotfiles
    ```
2. Run install script

    ```bash
    ./install.sh
    ```

## What's included

- `zshrc`: Zsh configuration
- `p10k.zsh`: Powerlevel10k theme configuration
- `gitconfig`: Git configuration
- `gitignore`: Global gitignore
- `vimrc`: Vim configuration
- `tmux.conf`: Tmux configuration
- `install.sh`: Automated installation script
- `claude-snapshot/`: Claude workflow snapshot — see "Claude Workflow Snapshot" below (only present on the `claude-setting` branch)
- `sync-claude.sh`: One-way snapshot updater (only present on the `claude-setting` branch)

---

## Claude Workflow Snapshot (branch: `claude-setting`)

This branch holds a one-way snapshot of the local Claude Code workflow assets:
`~/.claude/{CLAUDE.md, settings.json, agents/, hooks/, skills/}` and
`~/dev/.claude/{CLAUDE.md, codex-qa-prompt.xml}`.

**The dotfiles repo is a snapshot store, not a sync target.** The local install
is never touched by anything in this branch. Symlinks are not created.

### Update the snapshot (after local workflow edits)

```bash
~/dotfiles/sync-claude.sh
cd ~/dotfiles && git diff           # review
git add -A && git commit -m "..."   # commit on claude-setting
git push
```

### Apply to a new machine

1. Clone & checkout
   ```bash
   git clone https://github.com/minsubb13/dotfiles.git ~/dotfiles
   cd ~/dotfiles && git checkout claude-setting
   ```

2. Ask the local Claude Code to apply the snapshot:

   > Read `~/dotfiles/claude-snapshot/`. Following the "Machine-dependent
   > fields" table in this README, substitute the machine-dependent parts
   > of `settings.json`, `hooks/*.sh`, and `dev-claude/CLAUDE.md` to fit
   > this machine (NVM path, username, projects hash). Apply to
   > `~/.claude/` and `~/dev/.claude/`. Back up any existing files as
   > `<file>.bak.YYYYMMDD`.

3. Verify after Claude Code restart:
   - SessionStart hook surfaces workflow state (Codex QA count, last session-log)
   - statusLine renders correctly
   - PostToolUse hook appends to `~/.claude/projects/<hash>/workflow-metrics/codex-calls.log` after a `codex:codex-rescue` Agent call

### Machine-dependent fields

When applying the snapshot to a new machine, these are the only fields that
need to change. Everything else is portable.

| File / JSON path | Snapshot value (example) | New-machine substitute |
|---|---|---|
| `claude/settings.json` → `statusLine.command` (node path) | `/home/remote3/.nvm/versions/node/v24.13.1/bin/node` | `command -v node` 결과 또는 `~/.nvm/versions/node/<latest>/bin/node` |
| `claude/settings.json` → `hooks.SessionStart[0].hooks[0].command` | `/home/remote3/.claude/hooks/session-start-workflow-status.sh` | `$HOME/.claude/hooks/session-start-workflow-status.sh` |
| `claude/settings.json` → `hooks.Stop[0].hooks[0].command` | `/home/remote3/.claude/hooks/notify-stop.sh` | `$HOME/.claude/hooks/notify-stop.sh` |
| `claude/settings.json` → `hooks.PostToolUse[1].hooks[0].command` (hash 부분) | `~/.claude/projects/-home-remote3-dev/workflow-metrics/codex-calls.log` | 새 머신의 `~/dev` 절대경로를 hash한 디렉토리. Claude Code 컨벤션: `/`를 `-`로 치환 (예: `-home-<USERNAME>-dev`) |
| `dev-claude/CLAUDE.md` 본문의 hash 3군데 (line 70, 93, 100 부근) | `~/.claude/projects/-home-remote3-dev/...` | 위와 동일한 새 hash로 substitute |

### What is intentionally NOT in the snapshot

- `~/.claude/projects/<hash>/memory/` — auto memory. Conflict risk in two-machine setups.
- `~/.claude/projects/<hash>/workflow-metrics/` — per-machine accumulation.
- `~/dev/<project>/CLAUDE.md` — already lives in each project's git repo.
- `~/.claude/settings.local.json`, `~/dev/.claude/settings.local.json` — machine-specific MCP enablement.
- Symlinks. The local install is never linked to this repo.
