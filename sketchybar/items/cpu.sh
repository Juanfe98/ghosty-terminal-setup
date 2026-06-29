#!/usr/bin/env sh

sketchybar --add item cpu right                                        \
           --set cpu                                                  \
                 icon=$CPU                                            \
                 icon.color=$ORANGE                                   \
                 label.color=$WHITE                                   \
                 update_freq=5                                        \
                 script="$PLUGIN_DIR/cpu.sh"
