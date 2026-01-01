#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════╗
# ║ ░█▀▀░▀█▀░▀█▀░█░█░█░█░█▀▄░░░░░█▀█░█▀█░▀█▀░▀█▀░█▀▀░█░█ ║
# ║ ░█░█░░█░░░█░░█▀█░█░█░█▀▄░░░░░█░█░█░█░░█░░░█░░█▀▀░░█░ ║
# ║ ░▀▀▀░▀▀▀░░▀░░▀░▀░▀▀▀░▀▀░░▀▀▀░▀░▀░▀▀▀░░▀░░▀▀▀░▀░░░░▀░ ║
# ╚══════════════════════════════════════════════════════╝

set -euo pipefail
export LC_ALL=C.UTF-8

PASS_KEY=github/token/waybar
now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

token=$(pass show "$PASS_KEY" 2>/dev/null | tr -d '\n' || true)

# helper to output a single-line JSON object and exit
out() {
  jq -c -n --arg text "$1" --arg tooltip "$2" --arg class "$3" '{text:$text, tooltip:$tooltip, class:$class}'
  exit 0
}

if [[ -z $token ]]; then
  out "✗" "no token · last checked: $now" "error"
fi

# call API quietly, fail to empty string on error
resp=$(curl -sS -H "Authorization: token ${token}" "https://api.github.com/notifications" 2>/dev/null || echo "")

# validate JSON
if ! printf '%s' "$resp" | jq -e . >/dev/null 2>&1; then
  out "!" "api error · last checked: $now" "github-err"
fi

count=$(printf '%s' "$resp" | jq 'if type=="array" then length else 0 end')

if [[ $count -eq 0 ]]; then
  out "✓" "no notifications · last checked: $now" "github-ok"
fi

# Format up to 5 most recent notifications with nice spacing
tooltip=$(printf '%s' "$resp" | jq -r '
  limit(5; .[]) |
  "• \(.repository.full_name):\n    \(.subject.title) (\(.subject.type))"
')

out "$count" "$tooltip" "github"
