# Terminal & Neovim Dotfiles

Personal macOS terminal/dev-environment configuration. This repo keeps the source-of-truth files for Neovim, Ghostty, tmux, shell prompt/tools, and SketchyBar.

## What is included

```text
config/
  nvim/       Neovim Lua config managed with lazy.nvim
  ghostty/    Ghostty terminal config
  tmux/       tmux config
  atuin/      Atuin shell history config
fish/         Fish shell snippets
sketchybar/   SketchyBar config, items, plugins, and helper sources
starship/     Starship prompt config
.zshrc        Zsh shell config
README.md     Project documentation
```

Additional documentation:

- [`docs/neovim-sidesheet.md`](docs/neovim-sidesheet.md) — Neovim reference tailored to this config.
- [`docs/neovim-claude-tmux.md`](docs/neovim-claude-tmux.md) — Neovim + Claude Code tmux integration guide.

## Current status

This repository is **not currently symlinked** into `~/.config`. The live files under `~/.config/nvim`, `~/.config/ghostty`, `~/.config/tmux`, and `~/.config/atuin` are regular directories/files.

That means edits in this repo will not automatically affect the active local configuration until files are copied or symlinked.

## Recommended setup: use symlinks

The cleanest approach is to keep this repo as the source of truth and symlink each config into `~/.config`.

> Before doing this, back up your existing config directories.

```sh
mkdir -p ~/.config
mkdir -p ~/.config-backup

mv ~/.config/nvim ~/.config-backup/nvim 2>/dev/null || true
mv ~/.config/ghostty ~/.config-backup/ghostty 2>/dev/null || true
mv ~/.config/tmux ~/.config-backup/tmux 2>/dev/null || true
mv ~/.config/atuin ~/.config-backup/atuin 2>/dev/null || true

ln -s "$PWD/config/nvim" ~/.config/nvim
ln -s "$PWD/config/ghostty" ~/.config/ghostty
ln -s "$PWD/config/tmux" ~/.config/tmux
ln -s "$PWD/config/atuin" ~/.config/atuin
```

Optional prompt and shell integrations:

```sh
ln -s "$PWD/starship/starship.toml" ~/.config/starship.toml
ln -s "$PWD/.zshrc" ~/.zshrc
```

For SketchyBar, symlink or copy the folder depending on how SketchyBar is launched on the machine:

```sh
ln -s "$PWD/sketchybar" ~/.config/sketchybar
```

## Manual setup alternative

If you do not want symlinks, copy files manually:

```sh
cp -R config/nvim ~/.config/nvim
cp -R config/ghostty ~/.config/ghostty
cp -R config/tmux ~/.config/tmux
cp -R config/atuin ~/.config/atuin
```

The downside is that repo changes and live config changes can drift apart.

## Neovim overview

Neovim entrypoint:

```text
config/nvim/init.lua
```

Main modules:

```text
config/nvim/lua/config/options.lua   Editor options
config/nvim/lua/config/keymaps.lua   Custom keymaps
config/nvim/lua/config/lazy.lua      lazy.nvim bootstrap
config/nvim/lua/config/autocmds.lua  Autocommands
config/nvim/lua/plugins/init.lua     Plugin specs
```

Highlights:

- Plugin manager: `lazy.nvim`
- Theme: Catppuccin Mocha
- Fuzzy finding: Telescope
- Git: LazyGit, Diffview, Gitsigns
- LSP: Mason + nvim-lspconfig
- Completion: nvim-cmp + LuaSnip
- Formatting: conform.nvim
- Navigation: Harpoon, Aerial, Oil, nvim-tree
- Diagnostics: Trouble + tiny-inline-diagnostic

## Useful checks

Check whether live config paths are symlinks:

```sh
for p in nvim ghostty tmux atuin sketchybar; do
  if [ -L "$HOME/.config/$p" ]; then
    echo "$p -> $(readlink "$HOME/.config/$p")"
  elif [ -e "$HOME/.config/$p" ]; then
    echo "$p exists but is not a symlink"
  else
    echo "$p missing"
  fi
done
```

Check repo changes:

```sh
git status --short
```

## Notes

- This repo is tailored for a personal macOS setup.
- Some tools may require Homebrew packages or external CLIs to be installed separately.
- Neovim Mason is configured to use the public npm registry via `config/nvim/npmrc.mason`.
