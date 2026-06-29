#!/usr/bin/env sh

sketchybar --add item ram right                                        \
           --set ram                                                  \
                 icon=$RAM                                            \
                 icon.color=$TEAL                                     \
                 label.color=$WHITE                                   \
                 update_freq=10                                       \
                 script="$PLUGIN_DIR/ram.sh"
