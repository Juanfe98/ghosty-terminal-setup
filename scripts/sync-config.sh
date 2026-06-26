#!/usr/bin/env bash
#
# sync-config.sh — Pull live config from ~/.config (and $HOME) into this repo.
#
# Direction: LIVE -> REPO. The repo becomes a mirror of what you actually run,
# so you can review and commit the changes with git.
#
# Usage:
#   ./scripts/sync-config.sh            # sync everything
#   ./scripts/sync-config.sh --dry-run  # show what would change, copy nothing
#
# Notes:
#   - Directory pairs are mirrored with `rsync --delete`, so files removed from
#     the live config are also removed from the repo copy.
#   - `config/tmux/plugins/` is gitignored and never synced.
#   - Missing live sources are skipped with a warning (not an error).

set -euo pipefail

# Repo root = parent of this script's directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="$HOME/.config"

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

RSYNC_FLAGS=(-a --delete --human-readable)
(( DRY_RUN )) && RSYNC_FLAGS+=(--dry-run --itemize-changes)

# Directory pairs to mirror: "LIVE_SRC|REPO_DEST".
DIR_PAIRS=(
  "$CONFIG/nvim|$REPO_ROOT/config/nvim"
  "$CONFIG/ghostty|$REPO_ROOT/config/ghostty"
  "$CONFIG/tmux|$REPO_ROOT/config/tmux"
  "$CONFIG/atuin|$REPO_ROOT/config/atuin"
  "$CONFIG/sketchybar|$REPO_ROOT/sketchybar"
)

# Single-file pairs: "LIVE_SRC|REPO_DEST".
FILE_PAIRS=(
  "$HOME/.zshrc|$REPO_ROOT/.zshrc"
  "$HOME/.aerospace.toml|$REPO_ROOT/.aerospace.toml"
  "$CONFIG/starship.toml|$REPO_ROOT/starship/starship.toml"
)

# Per-destination excludes (keep gitignored / generated content out of the repo).
# Echoes a relative path to exclude for the given repo destination, or nothing.
# (Associative arrays are avoided for macOS bash 3.2 compatibility.)
exclude_for() {
  case "$1" in
    "$REPO_ROOT/config/tmux") echo "plugins" ;;
  esac
}

log()  { printf '  %s\n' "$*"; }
warn() { printf '  ! %s\n' "$*" >&2; }

sync_dir() {
  local src="$1" dest="$2"
  if [[ ! -d "$src" ]]; then
    warn "skip (missing): $src"
    return
  fi
  local flags=("${RSYNC_FLAGS[@]}")
  local excl
  excl="$(exclude_for "$dest")"
  if [[ -n "$excl" ]]; then
    flags+=(--exclude="$excl")
  fi
  mkdir -p "$dest"
  log "dir  $src/ -> $dest/"
  # Trailing slash on src copies contents into dest.
  rsync "${flags[@]}" "$src/" "$dest/"
}

sync_file() {
  local src="$1" dest="$2"
  if [[ ! -f "$src" ]]; then
    warn "skip (missing): $src"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  log "file $src -> $dest"
  rsync "${RSYNC_FLAGS[@]}" "$src" "$dest"
}

main() {
  (( DRY_RUN )) && echo "== DRY RUN (no changes written) =="
  echo "Pulling live config -> repo ($REPO_ROOT)"

  echo "Directories:"
  for pair in "${DIR_PAIRS[@]}"; do
    sync_dir "${pair%%|*}" "${pair##*|}"
  done

  echo "Files:"
  for pair in "${FILE_PAIRS[@]}"; do
    sync_file "${pair%%|*}" "${pair##*|}"
  done

  echo
  if (( DRY_RUN )); then
    echo "Dry run complete. Re-run without --dry-run to apply."
  else
    echo "Done. Review with: git status --short && git diff"
  fi
}

main "$@"
