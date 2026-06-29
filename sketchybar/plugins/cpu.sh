#!/usr/bin/env sh

source "$CONFIG_DIR/colors.sh"

# Sum per-process CPU and divide by core count for an overall utilization %.
CORES="$(sysctl -n hw.ncpu)"
CPU="$(ps -A -o %cpu | awk -v c="$CORES" 'NR>1 {s+=$1} END {printf "%.0f", s/c}')"

if [ "$CPU" -ge 80 ] 2>/dev/null; then
    COLOR=$RED
elif [ "$CPU" -ge 50 ] 2>/dev/null; then
    COLOR=$YELLOW
else
    COLOR=$ORANGE
fi

sketchybar --set "$NAME" icon.color="$COLOR" label="${CPU}%"
