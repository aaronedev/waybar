#!/usr/bin/env bash

# Get current workspace info
ws_json=$(hyprctl -j activeworkspace)
layout=$(echo "$ws_json" | jq -r '.tiledLayout // empty')

# Fallback to global if workspace field is missing or empty
if [[ -z $layout || $layout == "null" || $layout == "empty" ]]; then
  layout=$(hyprctl -j getoption general:layout | jq -r '.str // "dwindle"')
fi

hy3_info=""
if [[ $layout == "hy3" ]]; then
  count=$(echo "$ws_json" | jq -r '.windows')
  if [[ $count -gt 1 ]]; then
    # Make indicator more visible with color and spacing
    hy3_info=" <span color='#00fff9'>󰓢</span>"
  fi
fi

case "$layout" in
"dwindle")
  icon="󰕰"
  name="Dwindle"
  ;;
"master")
  icon="󰕯"
  name="Master"
  ;;
"hy3")
  icon="󰕮"
  name="Hy3${hy3_info}"
  ;;
"scrolling")
  icon="󰕬"
  name="Scrolling"
  ;;
"monocle")
  icon="󰕭"
  name="Monocle"
  ;;
*)
  icon="󰕰"
  name="${layout^}"
  ;;
esac

# Ensure name is not empty for printf
name="${name:-Dwindle}"

printf '{"text": "%s %s", "class": "%s", "tooltip": "Current Workspace Layout: %s"}\n' "$icon" "$name" "$layout" "$name"
