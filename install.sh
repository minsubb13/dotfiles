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
# 2. Oh My Zsh, Plugins & Symlinks
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

# Symlink dotfiles
echo "Creating symlinks for dotfiles..."

ln -sfv "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
ln -sfv "$DOTFILES_DIR/vimrc" "$HOME/.vimrc"
ln -sfv "$DOTFILES_DIR/p10k.zsh" "$HOME/.p10k.zsh"
ln -sfv "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
ln -sfv "$DOTFILES_DIR/gitignore" "$HOME/.gitignore"
ln -sfv "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"

# ------------------------------------------------------------------------------
# 3. Claude Code Configuration
# ------------------------------------------------------------------------------

echo ""
echo "Setting up Claude Code dotfiles..."

CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR/plugins/claude-hud"

# Detect runtime for templates
NODE_PATH=$(command -v node 2>/dev/null || echo "")
BUN_PATH=$(command -v bun 2>/dev/null || echo "")
RUNTIME="${BUN_PATH:-$NODE_PATH}"
NPX_PATH=""
if [ -n "$NODE_PATH" ]; then
    NPX_PATH="$(dirname "$NODE_PATH")/npx"
fi

# Generate settings.json from template (machine-specific paths)
if [ -f "$DOTFILES_DIR/claude/settings.json.template" ]; then
    sed -e "s|\\\$RUNTIME|${RUNTIME}|g" \
        -e "s|\\\$HOME|$HOME|g" \
        "$DOTFILES_DIR/claude/settings.json.template" > "$CLAUDE_DIR/settings.json"
    echo "  Generated settings.json"
fi

# Generate .mcp.json from template (machine-specific paths + secrets)
if [ -f "$DOTFILES_DIR/claude/mcp.json.template" ]; then
    NOTION_TOKEN="${NOTION_TOKEN:-\$NOTION_TOKEN}"
    sed -e "s|\\\$HOME|$HOME|g" \
        -e "s|\\\$NPX|${NPX_PATH}|g" \
        -e "s|\\\$NODE|${NODE_PATH}|g" \
        -e "s|\\\$NOTION_TOKEN|${NOTION_TOKEN}|g" \
        "$DOTFILES_DIR/claude/mcp.json.template" > "$HOME/.mcp.json"
    echo "  Generated ~/.mcp.json"
fi

# Symlink portable configs
ln -sfv "$DOTFILES_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
ln -sfv "$DOTFILES_DIR/claude/settings.local.json" "$CLAUDE_DIR/settings.local.json"
ln -sfv "$DOTFILES_DIR/claude/agents" "$CLAUDE_DIR/agents"
ln -sfv "$DOTFILES_DIR/claude/skills" "$CLAUDE_DIR/skills"
ln -sfv "$DOTFILES_DIR/claude/plugins/claude-hud/config.json" "$CLAUDE_DIR/plugins/claude-hud/config.json"

echo "Claude Code setup done."
if [ -z "$RUNTIME" ]; then
    echo "  Warning: node/bun not found - statusLine won't work until installed."
fi
echo "  Run 'claude login' to authenticate on this machine."

echo ""
echo "Setup complete! Please restart your terminal."
