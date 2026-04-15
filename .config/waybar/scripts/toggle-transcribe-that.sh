#!/usr/bin/env bash
# Toggle transcribe-that

mkdir -p "$HOME/transcribe-that/audio"
mkdir -p "$HOME/transcribe-that/transcripts"
mkdir -p "$HOME/.cache/transcribe-that/logs"
mkdir -p "$HOME/.cache/transcribe-that"

if pgrep -f "bin/transcribe-that" >/dev/null; then
  # Running - kill it
  pkill -f "bin/transcribe-that"
  rm -f "$HOME/.cache/transcribe-that/transcribe-that.pid"
  dunstctl close-all
  notify-send -i checkbox-checked "Transcribe" "Done — transcription saved"
else
  # Not running - start it
  # Record start time for duration tracking
  echo "$$ $(date +%s)" >"$HOME/.cache/transcribe-that/transcribe-that.pid"
  notify-send -u critical -i microphone "Transcribe" "Recording started..." -h "string:category:transcribe"
  # Run from home directory
  cd "$HOME" || exit
  transcribe-that-toggle \
    --notify \
    --out-dir "$HOME/transcribe-that" \
    --log-dir "$HOME/.cache/transcribe-that/logs" \
    &
fi
