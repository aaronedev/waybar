#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="$HOME/.local/share/hypr/.lid_inhibit"

if [[ -f $STATE_FILE ]]; then
  echo '{"text": "󰛊", "tooltip": "Lid Suspend Inhibited", "class": "inhibited"}'
else
  echo '{"text": "󰛈", "tooltip": "Lid Suspend Active", "class": "active"}'
fi
