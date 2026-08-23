# Dotfiles

Personal development environment configuration for macOS and Linux, covering the shell setup and the Claude Code workflow assets.

# Features

- **Shell**: Zsh with Oh My Zsh
- **Theme**: Powerlevel10k
- **Tools**: autojump, fzf, bat

## Prerequisites

Before installation, ensure you have the following installed:

- git
- vim
- zsh
- curl

## Installation

1. Clone this repository. The clone becomes the source of truth for every file it manages, so put it somewhere permanent — moving or deleting it later breaks every link that points into it.

    ```bash
    git clone https://github.com/minsubb13/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    ```

2. Run the install script.

    ```bash
    ./install.sh
    ```

Rerunning the script is safe. A link already pointing at the right place is left alone, and anything real sitting at a destination is moved under `~/.dotfiles-backup/<timestamp>/`, path intact, before the link takes its place. Backups land there rather than beside the original because Claude Code scans `~/.claude` for skills and agents and would otherwise read a saved copy back in as a duplicate.

## How it works

Every managed path is a symlink into this repository rather than a copy of it. Editing `~/.zshrc` therefore edits `zshrc` in the clone, and the change shows up under `git status` right away — capturing it takes nothing more than a commit and a push.

```
~/.zshrc              -> ~/dotfiles/zshrc
~/.claude/CLAUDE.md   -> ~/dotfiles/claude/CLAUDE.md
~/.claude/agents/     -> ~/dotfiles/claude/agents/
```

Anything that differs from machine to machine stays out of the repo, so a fresh clone behaves the same way everywhere.

## What's included

- `zshrc`: Zsh configuration
- `p10k.zsh`: Powerlevel10k theme configuration
- `gitconfig`: Git configuration
- `gitignore`: Global gitignore
- `vimrc`: Vim configuration
- `tmux.conf`: Tmux configuration
- `claude/`: Claude Code workflow assets — see below
- `install.sh`: Installation script; creates every link
- `docs/`: Design notes and analysis reports

## Machine-specific settings

Anything tied to one machine — a toolchain path, a host-specific credential helper — belongs in one of two files the repo does not track:

- `~/.zshrc.local`, sourced by `zshrc` when present
- `~/.gitconfig.local`, pulled in through an `[include]` directive in `gitconfig`

Both are optional. Zsh skips the source when the file is missing, and git ignores an include that points at nothing.

## Claude Code assets

`claude/` holds the hand-written half of the Claude Code setup, and `install.sh` links it into `~/.claude`:

| Repo path | Linked to | Linked as |
|---|---|---|
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | file |
| `claude/statusline-command.sh` | `~/.claude/statusline-command.sh` | file |
| `claude/agents/` | `~/.claude/agents/` | directory |
| `claude/hooks/` | `~/.claude/hooks/` | directory |
| `claude/skills/<name>/` | `~/.claude/skills/<name>/` | one link per skill |

`agents/` and `hooks/` are linked whole, so a new file dropped in either one lands in the repo without further setup. `skills/` is linked entry by entry instead, because `~/.claude/skills/` also holds links out to skills kept in other repositories, and those must stay untouched.

### What is deliberately not tracked

- `settings.json` — Claude Code and Orca rewrite it on their own, and it carries absolute paths that differ per machine. Configure it per machine and leave it out of version control.
- `settings.local.json` — per-machine MCP enablement.
- `plugins/`, `projects/`, `sessions/`, `history.jsonl` and the rest of `~/.claude` — runtime state owned by Claude Code.
- `scripts/` — deployed and updated by plugins, not by hand.
