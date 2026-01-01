#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════╗
# ║ ░█▀▀░▀█▀░▀█▀░█░█░█░█░█▀▄░░░░░█▀█░█▀█░▀█▀░▀█▀░█▀▀░█░█ ║
# ║ ░█░█░░█░░░█░░█▀█░█░█░█▀▄░░░░░█░█░█░█░░█░░░█░░█▀▀░░█░ ║
# ║ ░▀▀▀░▀▀▀░░▀░░▀░▀░▀▀▀░▀▀░░▀▀▀░▀░▀░▀▀▀░░▀░░▀▀▀░▀░░░░▀░ ║
# ╚══════════════════════════════════════════════════════╝

set -euo pipefail
export LC_ALL=C.UTF-8

PASS_KEY=github/token/waybar
TIMEOUT="${TIMEOUT:-8}"
now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

token=$(pass show "$PASS_KEY" 2>/dev/null | tr -d '\n' || true)
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
etag_path="${cache_dir}/github_notifications.etag"
resp_path="${cache_dir}/github_notifications.json"
mkdir -p "$cache_dir"

# helper to output a single-line JSON object and exit
out() {
  jq -c -n --arg text "$1" --arg tooltip "$2" --arg class "$3" '{text:$text, tooltip:$tooltip, class:$class}'
  exit 0
}

if [[ -z $token ]]; then
  out "✗" "no token · last checked: $now" "error"
fi

etag=""
if [[ -f "$etag_path" ]]; then
  etag=$(tr -d '\n' < "$etag_path")
fi

tmp_headers=$(mktemp)
tmp_body=$(mktemp)
cleanup() {
  rm -f "$tmp_headers" "$tmp_body"
}
trap cleanup EXIT

status=$(curl -sS --max-time "$TIMEOUT" \
  -H "Authorization: token ${token}" \
  ${etag:+-H "If-None-Match: $etag"} \
  -D "$tmp_headers" \
  -o "$tmp_body" \
  -w "%{http_code}" \
  "https://api.github.com/notifications" 2>/dev/null || echo "")

if [[ "$status" == "304" ]]; then
  resp=$(cat "$resp_path" 2>/dev/null || echo "")
elif [[ "$status" == "200" ]]; then
  resp=$(cat "$tmp_body")
  new_etag=$(awk -F': ' 'tolower($1)=="etag"{gsub("\r","",$2); print $2}' "$tmp_headers")
  if [[ -n "$new_etag" ]]; then
    printf '%s' "$new_etag" > "$etag_path"
  fi
  printf '%s' "$resp" > "$resp_path"
else
  resp=""
fi

# validate JSON
if ! printf '%s' "$resp" | jq -e . >/dev/null 2>&1; then
  out "!" "api error · last checked: $now" "github-err"
fi

count=$(printf '%s' "$resp" | jq 'if type=="array" then length else 0 end')

if [[ "$count" -eq 0 ]]; then
  out "✓" "no notifications · last checked: $now" "github-ok"
fi

tooltip=$(printf '%s' "$resp" | jq -r '.[0] | "\(.repository.full_name): \(.subject.title)"' | tr '\n' ' ')
out "$count" "$tooltip" "github"
