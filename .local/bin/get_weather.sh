#!/usr/bin/env bash

# waybar script for wttr.in
# Usage: get_weather.sh "Cologne, Germany"

CITY_RAW="${1:-Cologne, Germany}"
TIMEOUT="${TIMEOUT:-10}"
RETRIES=3

# trim leading/trailing whitespace
CITY_RAW="${CITY_RAW#"${CITY_RAW%%[![:space:]]*}"}"
CITY_RAW="${CITY_RAW%"${CITY_RAW##*[![:space:]]}"}"
CITY_QUERY="${CITY_RAW// /+}"

_strip_ansi() {
    printf '%s' "$1" | sed -r $'s/\x1b\[[0-9;]*[mK]//g'
}

# simple JSON escaper for bash strings
_json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    printf '%s' "$s"
}

for _ in $(seq 1 "$RETRIES"); do
    raw_text=$(curl -s --max-time "$TIMEOUT" "https://wttr.in/${CITY_QUERY}?format=%t") || raw_text=""
    [[ -z "$raw_text" ]] && sleep 1 && continue

    raw_text=$(_strip_ansi "$raw_text")
    text=$(printf '%s' "$raw_text" | tr -s '[:space:]' ' ')

    raw_current=$(curl -s --max-time "$TIMEOUT" "https://wttr.in/${CITY_QUERY}?format=%t") || raw_current="(current unavailable)"
    raw_forecast=$(curl -s --max-time "$TIMEOUT" "https://wttr.in/${CITY_QUERY}?format=Today:+%t\\nTomorrow:+%t\\nDay+after:+%t") || raw_forecast=""

    current=$(_strip_ansi "$raw_current")
    forecast=$(_strip_ansi "$raw_forecast")

    current=$(printf '%s' "$current" | sed -E 's/[[:space:]]+/ /g')
    forecast=$(printf '%s' "$forecast" | sed -E 's/[[:space:]]+/ /g')

    # Format forecast with proper alignment
    if [[ -n "$forecast" ]]; then
        forecast_formatted=$(printf '%s' "$forecast" | sed 's/Today:/\n📅 Today:    /; s/Tomorrow:/\n📅 Tomorrow:  /; s/Day after:/\n📅 Day after: /')
        tooltip="🌍 ${CITY_RAW}
━━━━━━━━━━━━━━━
📍 Current:    ${current}
${forecast_formatted}
━━━━━━━━━━━━━━━
🔄 Updated: $(date +'%H:%M')
💡 Left-click: Open wttr.in
🔄 Right-click: Refresh"
    else
        tooltip="🌍 ${CITY_RAW}
━━━━━━━━━━━━━━━
📍 Current:    ${current}
━━━━━━━━━━━━━━━
🔄 Updated: $(date +'%H:%M')
💡 Left-click: Open wttr.in
🔄 Right-click: Refresh"
    fi

    text_esc=$(_json_escape "$text")
    tooltip_esc=$(_json_escape "$tooltip")

    printf '{"text":"%s","tooltip":"%s"}\n' "$text_esc" "$tooltip_esc"
    exit 0
done

err_msg="⚠️ Weather unavailable"
err_tooltip="Failed to fetch weather data for ${CITY_RAW}\nCheck internet connection"
err_msg_esc=$(_json_escape "$err_msg")
err_tooltip_esc=$(_json_escape "$err_tooltip")
printf '{"text":"%s","tooltip":"%s"}\n' "$err_msg_esc" "$err_tooltip_esc"
exit 1
