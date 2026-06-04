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
ZSH_DISABLE_COMPFIX=true
DISABLE_AUTO_UPDATE=true
plugins=(
  git
  z
  sudo
  history
  colored-man-pages
)

DISABLE_MAGIC_FUNCTIONS=true
ZSH_COMPDUMP="${ZDOTDIR:-$HOME}/.zcompdump-${ZSH_VERSION}"
# Prevent inherited/exported FPATH or repeated `source ~/.zshrc` from duplicating
# completion paths, which can force slow compdump rebuilds.
typeset -gU fpath FPATH
typeset +x FPATH 2>/dev/null || true
source $ZSH/oh-my-zsh.sh

# =========================
# Paths
# =========================
# Homebrew is initialized in ~/.zprofile for login shells (Ghostty).
# Avoid running `brew shellenv` again here; spawning brew on every tab is slow.
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export PATH="./node_modules/.bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Python / pyenv (PATH only; full pyenv shell integration is lazy-loaded below)
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

# Starship config
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# =========================
# Tools
# =========================

# fzf — source static files instead of spawning `fzf --zsh` on every shell
if [[ -r /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi
if [[ -r /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/completion.zsh
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

# nvm — lazy load (saves ~10s on startup)
export NVM_DIR="$HOME/.nvm"
nvm() {
  # Remove lazy-loader stubs. Redirect because pnpm/yarn may not be functions.
  unfunction nvm node npm npx pnpm yarn 2>/dev/null
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
  nvm "$@"
}
node() { nvm use >/dev/null 2>&1; node "$@"; }
npm()  { nvm use >/dev/null 2>&1; npm  "$@"; }
npx()  { nvm use >/dev/null 2>&1; npx  "$@"; }
# pnpm/yarn don't need nvm auto-switch but stub if needed

# pyenv — lazy load to avoid `pyenv init` + `pyenv rehash` during terminal startup
pyenv() {
  unset -f pyenv
  eval "$(command pyenv init - zsh)"
  pyenv "$@"
}

# =========================
# Completion styling
# =========================
# compinit already called by Oh My Zsh above — skip duplicate

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
# alias pii="pnpm install"
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

# =========================
# Keychain helpers
# =========================
KPASS_REGISTRY="${HOME}/.kpass_registry"

# kpass-set <service> <account>  — store password (prompted securely, never in history)
kpass-set() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: kpass-set <service> <account>"
    return 1
  fi
  security add-generic-password -U -s "$1" -a "$2" -w
  echo "$1:$2" >> "$KPASS_REGISTRY"
  sort -u "$KPASS_REGISTRY" -o "$KPASS_REGISTRY"
  echo "Saved: $1 / $2"
}

# kpass-get <service> <account>  — retrieve password (copies to clipboard)
kpass-get() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: kpass-get <service> <account>"
    return 1
  fi
  local pass
  pass=$(security find-generic-password -s "$1" -a "$2" -w 2>/dev/null)
  if [[ -z "$pass" ]]; then
    echo "Not found: $1 / $2"
    return 1
  fi
  echo -n "$pass" | pbcopy
  echo "Copied to clipboard: $1 / $2"
}

# kpass-del <service> <account>  — delete a stored password
kpass-del() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: kpass-del <service> <account>"
    return 1
  fi
  security delete-generic-password -s "$1" -a "$2"
  [[ -f "$KPASS_REGISTRY" ]] && sed -i '' "/^$1:$2$/d" "$KPASS_REGISTRY"
  echo "Deleted: $1 / $2"
}

# kpass-list  — list all passwords stored via kpass-set
kpass-list() {
  if [[ ! -f "$KPASS_REGISTRY" ]] || [[ ! -s "$KPASS_REGISTRY" ]]; then
    echo "No passwords stored yet. Use: kpass-set <service> <account>"
    return
  fi
  echo "Stored credentials:"
  while IFS=: read -r svc acct; do
    echo "  $svc → $acct"
  done < "$KPASS_REGISTRY"
}

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

# . "$HOME/.atuin/bin/env"

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi
