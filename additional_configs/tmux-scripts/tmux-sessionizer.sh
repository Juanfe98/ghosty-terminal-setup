#!/usr/bin/env bash

set -eu

if [ -x /opt/homebrew/bin/fzf ]; then
  FZF_BIN=/opt/homebrew/bin/fzf
elif [ -x /usr/local/bin/fzf ]; then
  FZF_BIN=/usr/local/bin/fzf
elif command -v fzf >/dev/null 2>&1; then
  FZF_BIN="$(command -v fzf)"
else
  tmux display-message "tmux-sessionizer: fzf not found"
  exit 1
fi

SEARCH_ROOT="$HOME/Documents/repositories"

[ -d "$SEARCH_ROOT" ] || {
  tmux display-message "tmux-sessionizer: search root not found"
  exit 1
}

selected="$(
  find "$SEARCH_ROOT" \
    -mindepth 1 -maxdepth 2 -type d \
    ! -name '.*' \
    ! -name node_modules \
    ! -name dist \
    ! -name build \
    2>/dev/null \
    | sort \
    | "$FZF_BIN" --prompt='Project > ' --height=40% --layout=reverse --border
)"

[ -n "${selected:-}" ] || exit 0

case "$selected" in
  "$SEARCH_ROOT"/*)
    session_name="${selected#"$SEARCH_ROOT"/}"
    ;;
  *)
    session_name="$(basename "$selected")"
    ;;
esac

session_name="$(printf '%s' "$session_name" | tr '/. ' '___' | tr -cd '[:alnum:]_-')"

if [ -z "$session_name" ]; then
  tmux display-message "tmux-sessionizer: could not build session name"
  exit 1
fi

if ! tmux has-session -t "$session_name" 2>/dev/null; then
  # Create the session in the selected project directory.
  tmux new-session -d -s "$session_name" -c "$selected"

  # Configure the first window as "editor".
  tmux rename-window -t "${session_name}:1" exec
  tmux set-option -t "${session_name}:1" automatic-rename off

  # Create standard task windows.
  tmux new-window -t "$session_name" -n claude   -c "$selected"
  tmux set-option -t "${session_name}:2" automatic-rename off

  tmux new-window -t "$session_name" -n git   -c "$selected"
  tmux set-option -t "${session_name}:3" automatic-rename off

  tmux new-window -t "$session_name" -n tests -c "$selected"
  tmux set-option -t "${session_name}:4" automatic-rename off

  # Return focus to the editor window.
  tmux select-window -t "${session_name}:1"
fi

tmux switch-client -t "$session_name"
