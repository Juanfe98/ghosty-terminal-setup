#!/usr/bin/env sh

sketchybar --add item calendar right                                   \
           --set calendar                                             \
                 icon=$CALENDAR                                       \
                 icon.color=$MAGENTA                                  \
                 label.color=$WHITE                                   \
                 update_freq=30                                       \
                 script="$PLUGIN_DIR/calendar.sh"                     \
           --subscribe calendar system_woke
