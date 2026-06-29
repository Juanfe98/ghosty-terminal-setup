#!/usr/bin/env sh

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

PERCENTAGE="$(pmset -g batt | grep -Eo '[0-9]+%' | head -1 | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

# No battery (e.g. desktop) — hide the item.
if [ -z "$PERCENTAGE" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

case "$PERCENTAGE" in
    100|9[0-9]) ICON=$BATTERY_100; COLOR=$GREEN ;;
    [6-8][0-9]) ICON=$BATTERY_75;  COLOR=$GREEN ;;
    [3-5][0-9]) ICON=$BATTERY_50;  COLOR=$YELLOW ;;
    [1-2][0-9]) ICON=$BATTERY_25;  COLOR=$ORANGE ;;
    *)          ICON=$BATTERY_0;   COLOR=$RED ;;
esac

if [ -n "$CHARGING" ]; then
    ICON=$BATTERY_CHARGING
    COLOR=$GREEN
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
