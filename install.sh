#!/bin/bash

set -euo pipefail

OS="$(uname -s)"
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ------------------------------------------------------------------------------
# 1. Package Installation
# ------------------------------------------------------------------------------

if [ "$OS" = "Darwin" ]; then
    echo "macOS detected."

    # Install Homebrew
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew already installed."
    fi

    # Install plugins/tools via Brew
    echo "Installing tools via Homebrew..."
    brew install autojump bat fzf git vim zsh curl tmux

elif [ "$OS" = "Linux" ]; then
    echo "Linux (Ubuntu/Debian) detected."

    # Update and Install packages via apt
    sudo apt-get update
    sudo apt-get install -y zsh git vim curl autojump bat fzf fonts-powerline tmux

    # Handle 'bat' command name (Ubuntu installs it as 'batcat')
    mkdir -p ~/.local/bin
    [ -f /usr/bin/batcat ] && ln -sf /usr/bin/batcat ~/.local/bin/bat

    # Change default shell to zsh
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
    fi

else
    echo "Unsupported OS: $OS"
    exit 1
fi

# ------------------------------------------------------------------------------
# 2. Oh My Zsh & Plugins
# ------------------------------------------------------------------------------

# Install Oh My Zsh (--unattended prevents shell switch mid-script)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install powerlevel10k theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "Installing powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# Install zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Install zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ------------------------------------------------------------------------------
# 3. Link dotfiles into place
# ------------------------------------------------------------------------------

# The repo is the source of truth: every path below becomes a symlink into
# $DOTFILES_DIR, so editing the live file edits the repo and `git status`
# picks the change up straight away.
#
# Anything already sitting at a destination is preserved, never clobbered. A
# real file or directory is moved under ~/.dotfiles-backup/<timestamp>/ with
# its path kept intact; a symlink already pointing at the right place is left
# alone; a symlink pointing elsewhere is replaced.
#
# The backup deliberately lands outside ~/.claude. Claude Code scans that tree
# for skills and agents, so a saved copy left beside the original would be
# read back in as a duplicate.

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link_into_place() {
    local src="$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        echo "  skip  $dst (missing in repo: $src)"
        return
    fi

    if [ -L "$dst" ]; then
        if [ "$(readlink "$dst")" = "$src" ]; then
            echo "  ok    $dst"
            return
        fi
        rm -f "$dst"
    elif [ -e "$dst" ]; then
        local backup="$BACKUP_DIR/${dst#"$HOME"/}"
        mkdir -p "$(dirname "$backup")"
        mv "$dst" "$backup"
        echo "  saved $dst -> $backup"
    fi

    ln -s "$src" "$dst"
    echo "  link  $dst"
}

echo "Linking home dotfiles..."
for f in zshrc vimrc p10k.zsh gitconfig gitignore tmux.conf; do
    link_into_place "$DOTFILES_DIR/$f" "$HOME/.$f"
done

# ------------------------------------------------------------------------------
# 4. Link Claude Code workflow assets
# ------------------------------------------------------------------------------

# Only the hand-written assets are linked. ~/.claude also holds session logs,
# project state, plugins and settings.json, none of which belong in the repo:
# settings.json in particular is rewritten by Claude Code itself and carries
# absolute paths that differ per machine.
#
# agents/ and hooks/ are linked whole, so a new file there lands in the repo
# without further setup. skills/ is left out entirely: the ones on this machine
# are tied to environments that do not travel, and the directory also holds
# links out to skills kept in other repositories.

echo "Linking Claude Code assets..."
mkdir -p "$HOME/.claude"

link_into_place "$DOTFILES_DIR/claude/CLAUDE.md"             "$HOME/.claude/CLAUDE.md"
link_into_place "$DOTFILES_DIR/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
link_into_place "$DOTFILES_DIR/claude/agents"                "$HOME/.claude/agents"
link_into_place "$DOTFILES_DIR/claude/hooks"                 "$HOME/.claude/hooks"

echo ""
echo "Setup complete! Please restart your terminal."
echo "Machine-specific settings belong in ~/.zshrc.local and ~/.gitconfig.local,"
echo "both of which stay out of this repo."
