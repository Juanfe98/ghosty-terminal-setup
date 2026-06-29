#!/usr/bin/env sh

# AeroSpace fires this event on every workspace change (see aerospace.toml).
sketchybar --add event aerospace_workspace_change

SPACES=""
for sid in $(aerospace list-workspaces --all 2>/dev/null); do
    SPACES="$SPACES space.$sid"
    sketchybar --add item space."$sid" left                            \
        --subscribe space."$sid" aerospace_workspace_change            \
        --set space."$sid"                                             \
            icon="$sid"                                               \
            icon.color=$GREY                                          \
            icon.highlight_color=$WHITE                               \
            icon.padding_left=9                                       \
            icon.padding_right=9                                      \
            label.drawing=off                                        \
            background.color=$ACCENT_COLOR                            \
            background.corner_radius=6                                \
            background.height=22                                      \
            background.drawing=off                                    \
            click_script="aerospace workspace $sid"                  \
            script="$PLUGIN_DIR/aerospacer.sh $sid"
done

# Wrap all the workspace items in one rounded "bracket" background.
sketchybar --add bracket spaces $SPACES                                \
           --set spaces background.color=$BRACKET_COLOR               \
                        background.corner_radius=9                    \
                        background.height=28                          \
                        background.border_color=$BRACKET_BORDER_COLOR \
                        background.border_width=1

# Highlight the currently focused workspace right away (before the first switch).
sketchybar --trigger aerospace_workspace_change \
    FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused 2>/dev/null)"
