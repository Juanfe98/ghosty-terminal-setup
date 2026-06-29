#!/usr/bin/env sh

# Name of the currently focused application.
sketchybar --add item front_app left                                   \
           --subscribe front_app front_app_switched                    \
           --set front_app                                             \
                 icon.drawing=off                                     \
                 label.color=$WHITE                                   \
                 label.font="$FONT:Bold:13.0"                         \
                 background.drawing=off                               \
                 background.padding_left=10                           \
                 script="$PLUGIN_DIR/front_app.sh"

# Populate immediately (before the first app switch fires the event).
sketchybar --set front_app \
    label="$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null | cut -d'"' -f4)"
