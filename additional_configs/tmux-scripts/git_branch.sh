#!/usr/bin/env bash

path="$1"

[ -z "$path" ] && exit 0
[ ! -d "$path" ] && exit 0

branch="$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null)" || exit 0

if [ -n "$branch" ] && [ "$branch" != "HEAD" ]; then
  printf " %s" "$branch"
fi
