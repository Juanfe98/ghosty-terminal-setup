#!/usr/bin/env sh

source "$CONFIG_DIR/colors.sh"

# Used = active + wired + compressed (matches the tmux ram_usage.sh method:
# reclaimable cache is not counted as "used").
page_size="$(vm_stat | awk '/page size of/ {print $8}')"
[ -n "$page_size" ] || page_size=4096
total_bytes="$(sysctl -n hw.memsize 2>/dev/null)"

USED="$(vm_stat | awk -v ps="$page_size" -v tot="$total_bytes" '
    function clean(v) { gsub("\\.", "", v); return v + 0 }
    /Pages active/                  { active = clean($3) }
    /Pages wired down/              { wired = clean($4) }
    /Pages occupied by compressor/  { compressed = clean($5) }
    END { printf "%.0f", (active + wired + compressed) * ps / tot * 100 }
')"

if [ "$USED" -ge 85 ] 2>/dev/null; then
    COLOR=$RED
elif [ "$USED" -ge 65 ] 2>/dev/null; then
    COLOR=$YELLOW
else
    COLOR=$TEAL
fi

sketchybar --set "$NAME" icon.color="$COLOR" label="${USED}%"
