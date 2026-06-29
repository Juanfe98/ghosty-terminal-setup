#!/usr/bin/env sh

# ── Catppuccin Macchiato palette ────────────────────────────────────────────
BLACK=0xff181926
WHITE=0xffcad3f5
RED=0xffed8796
GREEN=0xffa6da95
BLUE=0xff8aadf4
YELLOW=0xffeed49f
ORANGE=0xfff5a97f
MAGENTA=0xffc6a0f6
TEAL=0xff8bd5ca
PINK=0xfff5bde6
GREY=0xff939ab7
TRANSPARENT=0x00000000

# Surfaces (used for item / bracket backgrounds)
BASE=0xff24273a
MANTLE=0xff1e2030
CRUST=0xff181926
SURFACE0=0xff363a4f
SURFACE1=0xff494d64
SURFACE2=0xff5b6078

# ── Semantic colors ─────────────────────────────────────────────────────────
ACCENT_COLOR=$BLUE                # active workspace / highlights

BAR_COLOR=0xe61e2030              # translucent mantle, pairs with blur
BAR_BORDER_COLOR=0xff494d64

ICON_COLOR=$WHITE
LABEL_COLOR=$WHITE

# Grouped "bracket" background + per-item pill background
BRACKET_COLOR=0x99363a4f
BRACKET_BORDER_COLOR=0xff494d64
ITEM_BG_COLOR=0xff363a4f

POPUP_BACKGROUND_COLOR=0xff1e2030
POPUP_BORDER_COLOR=$SURFACE2

SHADOW_COLOR=$BLACK

# Item specific special colors
SPOTIFY_GREEN=$GREEN
