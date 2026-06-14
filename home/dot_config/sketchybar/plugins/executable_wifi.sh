#!/bin/bash
# Dim the wifi icon when en0 isn't connected (avoids SSID/location-permission
# hassle on recent macOS).
export PATH="/opt/homebrew/bin:$PATH"

if ifconfig en0 2>/dev/null | grep -q "status: active"; then
  sketchybar --set "$NAME" icon.color=0xffcdd6f4
else
  sketchybar --set "$NAME" icon.color=0xff6c7086
fi
