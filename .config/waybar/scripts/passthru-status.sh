#!/usr/bin/env bash
# Monitors if passthru submap is active and outputs JSON for waybar

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-passthru.state"

if [[ -f "$STATE_FILE" ]]; then
  echo '{"text": "ESC", "class": "passthru-active", "tooltip": "Passthru mode active - Press Super+Escape to exit"}'
else
  echo '{"text": "", "class": ""}'
fi