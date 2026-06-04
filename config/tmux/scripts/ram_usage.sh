#!/bin/sh

# macOS RAM usage for tmux status line.
# Uses active + wired + compressed memory, which is close to what you care
# about during development without counting easily reclaimable cache as "used".

page_size=$(vm_stat | awk '/page size of/ {print $8}')
[ -n "$page_size" ] || page_size=4096

total_bytes=$(sysctl -n hw.memsize 2>/dev/null)

vm_stat | awk -v page_size="$page_size" -v total_bytes="$total_bytes" '
function clean(value) {
  gsub("\\.", "", value)
  return value + 0
}
/Pages active/ { active = clean($3) }
/Pages wired down/ { wired = clean($4) }
/Pages occupied by compressor/ { compressed = clean($5) }
END {
  used_bytes = (active + wired + compressed) * page_size
  used_gib = used_bytes / 1024 / 1024 / 1024
  total_gib = total_bytes / 1024 / 1024 / 1024
  used_pct = used_bytes / total_bytes * 100

  printf "󰍛 %.0f%% %.1f/%.0fG", used_pct, used_gib, total_gib
}
'
