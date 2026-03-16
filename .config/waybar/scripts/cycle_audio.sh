#!/usr/bin/env bash
set -euo pipefail

# Get list of all sink IDs
sinks=($(wpctl status | grep -A 20 "Sinks:" | grep -E '^[[:space:]]*(\*| )[[:space:]]*[0-9]+\.' | sed -E 's/^[[:space:]]*(\*| )[[:space:]]*([0-9]+)\..*/\2/'))

if [[ ${#sinks[@]} -le 1 ]]; then
  dunstify -a "Audio" -u low "Audio Switch" "Only one output device available"
  exit 0
fi

# Find current default sink ID
current_sink=$(wpctl status | grep -A 20 "Sinks:" | grep '^[[:space:]]*\*' | sed -E 's/^[[:space:]]*\*[[:space:]]*([0-9]+)\..*/\1/')

# Find index of current sink
current_idx=-1
for i in "${!sinks[@]}"; do
  if [[ ${sinks[$i]} == "$current_sink" ]]; then
    current_idx=$i
    break
  fi
done

# Calculate next index
next_idx=$(((current_idx + 1) % ${#sinks[@]}))
next_sink="${sinks[$next_idx]}"

# Set new default sink
wpctl set-default "$next_sink"

# Get name of new sink for notification
sink_name=$(wpctl status | grep -A 20 "Sinks:" | grep "^[[:space:]]*.[[:space:]]*$next_sink\." | sed -E "s/^[[:space:]]*.[[:space:]]*$next_sink\.[[:space:]]*(.*)\[vol:.*/\1/" | xargs)

dunstify -a "Audio" -i "audio-speakers-symbolic" -r "9997" "Audio Output Switched" "Active: $sink_name"
