#!/bin/bash
# Battery percentage with a charging-aware icon.
export PATH="/opt/homebrew/bin:$PATH"

PERCENT="$(pmset -g batt | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"
[ -z "$PERCENT" ] && exit 0

if pmset -g batt | grep -q 'AC Power'; then
  ICON=""
else
  ICON=""
fi

sketchybar --set "$NAME" icon="$ICON" label="${PERCENT}%"
