#!/bin/bash
# Date + time.
export PATH="/opt/homebrew/bin:$PATH"

sketchybar --set "$NAME" label="$(date '+%a %d %b  %H:%M')"
