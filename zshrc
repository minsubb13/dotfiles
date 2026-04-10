# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# ------------------------------------------------------------------------------
# OS Specific Settings (macOS vs Linux)
# ------------------------------------------------------------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS Specific
    CPU=$(uname -m)
    if [[ "$CPU" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    alias ibrew="arch -x86_64 /usr/local/bin/brew"
    alias abrew="arch -arm64 /opt/homebrew/bin/brew"

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Ubuntu/Linux Specific

    # Fix 'bat' command mapping if not already in path
    export PATH="$HOME/.local/bin:$PATH"

    # Autojump for Ubuntu (installed via apt)
    if [ -f /usr/share/autojump/autojump.sh ]; then
        . /usr/share/autojump/autojump.sh
    fi
fi

# Plugins
plugins=(
  git
  history
  dirhistory
  autojump
  fzf
)

source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8

# powerlevel10k theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# zsh plugins (installed manually or via apt/brew)
source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# ------------------------------------------------------------------------------
# FZF Configuration (Cross-platform)
# ------------------------------------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Check if brew exists (macOS) or fallback to system paths
if (( $+commands[brew] )); then
    source "$(brew --prefix)/opt/fzf/shell/completion.zsh" 2> /dev/null
    source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh" 2> /dev/null
elif [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
    # Ubuntu apt package path
    source /usr/share/doc/fzf/examples/completion.zsh 2> /dev/null
    source /usr/share/doc/fzf/examples/key-bindings.zsh 2> /dev/null
fi

alias home='cd $HOME'
alias cld='claude --dangerously-skip-permissions'

# ------------------------------------------------------------------------------
# Machine-local settings: source ~/.zshrc.local if it exists
# ------------------------------------------------------------------------------
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
