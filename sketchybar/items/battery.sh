#!/usr/bin/env sh

sketchybar --add item battery right                                    \
           --set battery                                              \
                 icon=$BATTERY_100                                    \
                 icon.color=$GREEN                                    \
                 label.color=$WHITE                                   \
                 update_freq=120                                      \
                 script="$PLUGIN_DIR/battery.sh"                      \
           --subscribe battery system_woke power_source_change
