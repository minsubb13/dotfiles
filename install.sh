#!/bin/bash

# Install Homebrew
if ! command -v brew &> /dev/null
then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew already installed."
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh not found. Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh already installed."
fi

# Install plugins for zsh
echo "Installing plugins for zsh..."
brew install autojump bat fzf

# Install antigen for zsh
if [ ! -f "$HOME/.antigen.zsh" ]; then
    echo "Installing antigen..."
    curl -L git.io/antigen > ~/.antigen.zsh
else
    echo "Antigen already installed."
fi

# Symlink dotfiles
echo "Creating symlinks for dotfiles..."
DOTFILES_DIR=$(pwd)

ln -sfv "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
ln -sfv "$DOTFILES_DIR/vimrc" "$HOME/.vimrc"
ln -sfv "$DOTFILES_DIR/p10k.zsh" "$HOME/.p10k.zsh"
ln -sfv "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
ln -sfv "$DOTFILES_DIR/gitignore" "$HOME/.gitignore"

echo "Setup complete!"
