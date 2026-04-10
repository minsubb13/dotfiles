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
- `claude/`: Claude Code configuration (see below)

## Claude Code

`install.sh`를 실행하면 Claude Code 설정도 함께 적용됩니다.

### 포함 항목

| 파일 | 용도 | 설치 방식 |
|------|------|-----------|
| `claude/CLAUDE.md` | 글로벌 지시사항 (코드 스타일, 커밋 규칙 등) | symlink |
| `claude/settings.json.template` | 플러그인, 마켓플레이스, HUD 설정 | 템플릿 -> 생성 |
| `claude/settings.local.json` | MCP 서버 승인 목록 | symlink |
| `claude/mcp.json.template` | MCP 서버 설정 (Notion 등) | 템플릿 -> 생성 |
| `claude/agents/` | 커스텀 에이전트 (tracer, architect, scientist, security-reviewer) | symlink |
| `claude/skills/` | 커스텀 스킬 (docs-summary) | symlink |
| `claude/plugins/claude-hud/config.json` | HUD 표시 설정 | symlink |

### 새 머신에서 설치

```bash
# 1. 레포 클론 및 설치 (NOTION_TOKEN은 환경변수로 주입)
git clone https://github.com/minsubb13/dotfiles.git ~/dotfiles
cd ~/dotfiles
NOTION_TOKEN=ntn_xxxxx bash install.sh

# 2. Claude Code 인증
claude login

# 3. Claude Code 시작 - 플러그인은 마켓플레이스에서 자동 설치됨
claude
```

### 템플릿 변수

`settings.json.template`과 `mcp.json.template`에는 머신별 경로 플레이스홀더가 있으며, `install.sh`가 자동으로 치환합니다.

| 변수 | 설명 | 감지 방법 |
|------|------|-----------|
| `$RUNTIME` | node 또는 bun 절대 경로 | `command -v bun \|\| command -v node` |
| `$NPX` | npx 절대 경로 | node 경로에서 유도 |
| `$HOME` | 홈 디렉토리 | 환경변수 |
| `$NOTION_TOKEN` | Notion API 토큰 | 환경변수로 주입 |

### 설정 수정 후

symlink된 파일(CLAUDE.md, agents/ 등)은 dotfiles 레포에서 직접 수정 -> commit -> push하면 됩니다. 생성된 파일(settings.json, .mcp.json)은 템플릿을 수정 후 `install.sh`를 다시 실행합니다.

