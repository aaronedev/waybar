#!/usr/bin/env bash
# Status script for transcribe-that waybar module

if pgrep -f "bin/transcribe-that" >/dev/null; then
  echo '{"text": "", "class": "running", "tooltip": "transcribe-that running (click to stop)"}'
else
  echo '{"text": "", "class": "idle", "tooltip": "transcribe-that - click to start"}'
fi
