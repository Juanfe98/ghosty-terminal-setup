#!/usr/bin/env sh

sketchybar --add item clock right                                      \
           --set clock                                                \
                 icon=$CLOCK                                          \
                 icon.color=$BLUE                                     \
                 label.color=$WHITE                                   \
                 update_freq=10                                       \
                 script="$PLUGIN_DIR/clock.sh"                        \
           --subscribe clock system_woke
