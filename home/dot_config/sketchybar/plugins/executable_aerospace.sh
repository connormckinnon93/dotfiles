#!/bin/bash
# Highlight the focused AeroSpace workspace. $1 = this item's workspace id;
# FOCUSED_WORKSPACE is provided by the aerospace_workspace_change event.
export PATH="/opt/homebrew/bin:$PATH"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" background.drawing=on label.color=0xff11111b
else
  sketchybar --set "$NAME" background.drawing=off label.color=0xffcdd6f4
fi
