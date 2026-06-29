#!/usr/bin/env bash
# install.sh — create symlinks from this repo to the system dotfile locations.
# Anything already at a target path is backed up before being replaced.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC}  $*"; }
warn() { echo -e "${YELLOW}!${NC}  $*"; }
err()  { echo -e "${RED}✗${NC}  $*"; exit 1; }

# Create a symlink from $2 (system path) → $1 (repo path).
# Backs up anything already at the destination, preserving the directory structure.
link() {
  local src="$1" dst="$2"

  # Already pointing to the right place — nothing to do.
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    ok "Already linked:  $dst"
    return
  fi

  # Back up whatever is currently at the destination.
  if [[ -e "$dst" || -L "$dst" ]]; then
    local rel="${dst#"$HOME/"}"
    local bak="$BACKUP/$rel"
    mkdir -p "$(dirname "$bak")"
    mv "$dst" "$bak"
    warn "Backed up:       $dst"
    warn "             →   $bak"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  ok "Linked:          $dst"
  ok "             →   $src"
}

echo ""
echo "Dotfiles installer"
echo "  Repo:   $REPO"
echo "  Backup: $BACKUP"
echo ""

# ── Shell ──────────────────────────────────────────────────────────────────────
link "$REPO/.zshrc"                       "$HOME/.zshrc"

# ── Terminal apps ──────────────────────────────────────────────────────────────
link "$REPO/config/ghostty"               "$HOME/.config/ghostty"
link "$REPO/config/nvim"                  "$HOME/.config/nvim"
link "$REPO/config/tmux"                  "$HOME/.config/tmux"
link "$REPO/config/atuin"                 "$HOME/.config/atuin"

# ── Starship prompt ────────────────────────────────────────────────────────────
# starship.toml lives under starship/ at the repo root, not inside config/,
# so it needs its parent directory created explicitly.
link "$REPO/starship/starship.toml"       "$HOME/.config/starship/starship.toml"

# ── macOS-only ─────────────────────────────────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
  link "$REPO/sketchybar"                 "$HOME/.config/sketchybar"
  link "$REPO/config/aerospace"           "$HOME/.config/aerospace"
fi

# ── Fish shell ─────────────────────────────────────────────────────────────────
# Only link our specific file — the rest of ~/.config/fish belongs to the system.
link "$REPO/fish/conf.d/atuin.env.fish"   "$HOME/.config/fish/conf.d/atuin.env.fish"

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
if [[ -d "$BACKUP" ]]; then
  ok "Backup saved to: $BACKUP"
  echo ""
  echo "  To restore a file:"
  echo "    rm <symlink>"
  echo "    mv $BACKUP/<relative-path> <original-location>"
  echo ""
fi
ok "Done!"
echo ""
