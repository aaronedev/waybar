#!/usr/bin/env bash
# Status script for transcribe-that waybar module

PIDFILE="$HOME/.cache/transcribe-that/transcribe-that.pid"

is_running() {
  pgrep -f "bin/transcribe-that" >/dev/null 2>&1
}

get_elapsed() {
  if [[ -f $PIDFILE ]]; then
    read -r pid started <"$PIDFILE"
    if [[ -n $pid && -n $started ]] && kill -0 "$pid" 2>/dev/null; then
      local now=$(date +%s)
      local elapsed=$((now - started))
      local mins=$((elapsed / 60))
      local secs=$((elapsed % 60))
      printf "%02d:%02d" $mins $secs
      return 0
    fi
  fi
  return 1
}

if is_running; then
  elapsed=$(get_elapsed)
  if [[ -n $elapsed ]]; then
    echo "{\"text\": \"󰍰 ${elapsed}\", \"class\": \"running\", \"tooltip\": \"Recording: ${elapsed} (click to stop)\"}"
  else
    echo '{"text": "󰍰", "class": "running", "tooltip": "transcribe-that running (click to stop)"}'
  fi
else
  echo '{"text": "", "class": "idle", "tooltip": "transcribe-that - click to start"}'
fi
