#!/usr/bin/env bash
STATE_FILE="$HOME/.cache/waybar-tray-hidden"
CSS_FILE="$HOME/.config/waybar/tray-state.css"

if [[ ${1:-toggle} == "toggle" ]]; then
  if [[ -f $STATE_FILE ]]; then
    rm "$STATE_FILE"
  else
    touch "$STATE_FILE"
  fi
fi

if [[ -f $STATE_FILE ]]; then
  # TODO: Refactor tray toggle to use a more reliable GTK hiding method.
  # BUG: When collapsed, the tray module might not physically minimize or hide icons correctly in some Waybar versions.
  # Completely collapse and hide tray using valid GTK CSS
  echo '#tray { margin: 0; padding: 0; min-width: 0; opacity: 0; }' >"$CSS_FILE"
  printf '{"text": "󰅂", "class": "hidden", "tooltip": "Tray hidden (Click to show)"}\n'
else
  # Restore tray
  echo '#tray { margin-right: 0.4rem; opacity: 1; min-width: 1.25rem; }' >"$CSS_FILE"
  printf '{"text": "󰅁", "class": "visible", "tooltip": "Tray visible (Click to hide)"}\n'
fi

# Reload waybar style if it was a toggle
if [[ ${1:-} == "toggle" ]]; then
  killall -SIGUSR2 waybar
fi
