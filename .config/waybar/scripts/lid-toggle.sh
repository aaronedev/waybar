#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="$HOME/.local/share/hypr/.lid_inhibit"
mkdir -p "$(dirname "$STATE_FILE")"

if [[ -f $STATE_FILE ]]; then
  rm "$STATE_FILE"
  notify-send -u low "Lid" "Lid suspend ENABLED"
else
  touch "$STATE_FILE"
  notify-send -u low "Lid" "Lid suspend INHIBITED"
fi

# Reload Waybar if it doesn't have an interval (it's better to reload to see change instantly)
pkill -RTMIN+11 waybar || true
