#!/bin/bash
# Show the name of the focused application.
export PATH="/opt/homebrew/bin:$PATH"

if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set "$NAME" label="$INFO"
fi
