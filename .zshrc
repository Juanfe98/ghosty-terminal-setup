# =========================
# Core shell behavior
# =========================
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R"
export LANG="en_US.UTF-8"

# History
HISTSIZE=100000
SAVEHIST=100000
HISTFILE="$HOME/.zsh_history"
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt EXTENDED_HISTORY

# Navigation / UX
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt AUTO_MENU

# =========================
# Oh My Zsh
# =========================
ZSH_THEME="robbyrussell"
plugins=(
  git
  z
  sudo
  history
  colored-man-pages
  command-not-found
)

source $ZSH/oh-my-zsh.sh

# =========================
# Homebrew
# =========================
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# =========================
# Paths
# =========================
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
export PATH="./node_modules/.bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Python
export PATH="$HOME/.pyenv/bin:$PATH"

# Starship config
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# =========================
# Tools
# =========================

# fzf
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# direnv
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# starship (optional prompt)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
fi
if [[ -s "$NVM_DIR/bash_completion" ]]; then
  source "$NVM_DIR/bash_completion"
fi

# pyenv
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi

# =========================
# Completion styling
# =========================
autoload -Uz compinit && compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# =========================
# Useful aliases
# =========================

# General
alias c="clear"
alias q="exit"
alias reload="source ~/.zshrc"
alias zshconfig="$EDITOR ~/.zshrc"
alias ohmyzsh="$EDITOR ~/.oh-my-zsh"
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first"
alias lt="eza --tree --level=2 --icons"
alias cat="bat"
alias grep="rg"
alias find="fd"

# Git
# alias g="git"
# alias gs="git status"
# alias ga="git add"
# alias gaa="git add ."
# alias gc="git commit"
# alias gcm="git commit -m"
# alias gca="git commit --amend"
# alias gco="git checkout"
# alias gcb="git checkout -b"
# alias gb="git branch"
# alias gba="git branch -a"
# alias gd="git diff"
# alias gds="git diff --staged"
# alias gl="git log --oneline --graph --decorate --all"
# alias gp="git push"
# alias gpf="git push --force-with-lease"
# alias gpl="git pull --rebase"
# alias gst="git stash"
# alias gsta="git stash apply"
# alias gsw="git switch"
# alias gclean="git branch --merged | egrep -v '(^\\*|main|master|develop|dev)' | xargs git branch -d"

# Node / JS
alias ni="npm install"
alias nr="npm run"
alias ns="npm start"
alias nt="npm test"
alias nid="npm install --save-dev"
alias pi="pnpm install"
alias pr="pnpm run"
alias pt="pnpm test"
alias py="python3"

# Docker
alias d="docker"
alias dc="docker compose"
alias dps="docker ps"
alias dimg="docker images"
alias dcu="docker compose up"
alias dcud="docker compose up -d"
alias dcd="docker compose down"
alias dcl="docker compose logs -f"

# Kubernetes
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get svc"
alias kgd="kubectl get deploy"
alias kctx="kubectl config current-context"

# Tmux
alias ta="tmux attach -t"
alias tls="tmux ls"
alias tn="tmux new -s"
alias tmux='tmux -f ~/.config/tmux/tmux.conf'

# =========================
# Functions
# =========================

# Make directory and enter it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Git branch with fzf
# gbr() {
#   local branch
#   branch=$(git for-each-ref --sort=-committerdate refs/heads refs/remotes --format='%(refname:short)' \
#     | awk '!seen[$0]++' \
#     | fzf --height=40% --reverse --prompt="Checkout branch > ") || return
#   git checkout "$branch"
# }

# Git log picker
# glog() {
#   git log --oneline --graph --decorate --all | fzf --ansi --no-sort --reverse --height=60%
# }

# Kill process on port
portkill() {
  local port="$1"
  if [[ -z "$port" ]]; then
    echo "Usage: portkill <port>"
    return 1
  fi
  lsof -ti :"$port" | xargs kill -9
}

# Extract almost anything
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo "Cannot extract '$1'" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Fuzzy cd into project directories
cdf() {
  local dir
  dir=$(fd . "$HOME/Documents" "$HOME/projects" "$HOME/work" --type d 2>/dev/null | fzf --height=40% --reverse) || return
  cd "$dir"
}

# Create + enter tmux session from current dir
tks() {
  local session_name
  session_name=$(basename "$(pwd)" | tr '.' '_')
  tmux new-session -A -s "$session_name"
}

# Quick repo status overview
repohealth() {
  echo "Branch: $(git branch --show-current)"
  echo ""
  git status --short
  echo ""
  git log --oneline -5
}

# =========================
# Key bindings
# =========================
bindkey '^R' history-incremental-search-backward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# =========================
# Prompt extras
# =========================
autoload -Uz colors && colors

# Show command execution time if long
REPORTTIME=5

# =========================
# Local overrides
# =========================
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
