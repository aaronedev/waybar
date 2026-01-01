#!/usr/bin/env bash
# Status script for read-that waybar module

if pgrep -f "python -m read_that" >/dev/null; then
  echo '{"text": "", "class": "running", "tooltip": "read-that running (click to stop)"}'
else
  echo '{"text": "", "class": "idle", "tooltip": "read-that - click to start"}'
fi
