#!/usr/bin/env bash
# Toggle transcribe-that

# Ensure directories exist
mkdir -p "$HOME/transcribe-that/audio"
mkdir -p "$HOME/transcribe-that/transcripts"
mkdir -p "$HOME/.cache/transcribe-that/logs"

if pgrep -f "bin/transcribe-that" >/dev/null; then
  # Running - kill it
  pkill -f "bin/transcribe-that"
  notify-send -t 2000 "Transcribe" "Stopping recording and starting transcription..."
else
  # Not running - start it
  notify-send -t 2000 "Transcribe" "Recording started..."
  # Run from home directory
  cd "$HOME"
  transcribe-that \
    --notify \
    --out-dir "$HOME/transcribe-that" \
    --log-dir "$HOME/.cache/transcribe-that/logs" \
    &
fi
