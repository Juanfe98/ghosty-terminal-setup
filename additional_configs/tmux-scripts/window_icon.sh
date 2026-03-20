#!/usr/bin/env bash

window_id="$1"

[ -z "$window_id" ] && exit 0

cmd="$(tmux display-message -p -t "$window_id" "#{pane_current_command}" 2>/dev/null | tr '[:upper:]' '[:lower:]')"

case "$cmd" in
  nvim|vim)
    printf ""
    ;;
  zsh|bash|fish)
    printf ""
    ;;
  node|npm|pnpm|yarn)
    printf ""
    ;;
  git|lazygit)
    printf "󰊢"
    ;;
  python|python3|uv|ipython)
    printf ""
    ;;
  docker|docker-compose)
    printf ""
    ;;
  ssh)
    printf "󰣀"
    ;;
  htop|btop)
    printf ""
    ;;
  code|cursor)
    printf "󰨞"
    ;;
  *)
    printf ""
    ;;
esac
