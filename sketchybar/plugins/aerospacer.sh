#!/bin/bash

# $1 is the workspace id this item represents; FOCUSED_WORKSPACE is set by the
# aerospace_workspace_change event trigger. Highlight the focused one.
if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" background.drawing=on icon.highlight=on
else
    sketchybar --set "$NAME" background.drawing=off icon.highlight=off
fi

