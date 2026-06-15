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
# 2. Oh My Zsh, Plugins & Dotfiles
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

# Copy dotfiles into place (plain copies, not symlinks)
echo "Copying dotfiles..."

# rm first so an existing symlink is replaced by a real file instead of
# being followed (which would overwrite the repo source).
for f in zshrc vimrc p10k.zsh gitconfig gitignore tmux.conf; do
    rm -f "$HOME/.$f"
    cp "$DOTFILES_DIR/$f" "$HOME/.$f"
done

echo ""
echo "Setup complete! Please restart your terminal."
