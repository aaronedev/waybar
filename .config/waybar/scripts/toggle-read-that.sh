#!/usr/bin/env bash
# Toggle read-that terminal

if pgrep -f "python -m read_that" >/dev/null; then
  # Running - kill it
  pkill -f "python -m read_that"
else
  # Not running - start it
  read-that &
fi
