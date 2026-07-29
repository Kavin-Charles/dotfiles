#!/usr/bin/env bash
set -euo pipefail

menu() {
    read -r x y < <(hyprctl cursorpos | tr , ' ')
    read -r w < <(hyprctl monitors -j | jq -r '.[] | select(.focused).width' 2>/dev/null || echo 1920)
    x=$(( x + 10 > w - 400 ? w - 410 : x < 10 ? 10 : x + 10 ))
    wofi --dmenu --insensitive --prompt "$1" --matching fuzzy --width 400 --lines 8 --cache-file /dev/null --location 0 --xoffset "$x" --yoffset 30
}

info=$(upower -i $(upower -e | grep BAT) 2>/dev/null)
[ -z "$info" ] && { command -v notify-send >/dev/null && notify-send "Battery" "No battery found"; exit 1; }

percentage=$(echo "$info" | awk -F':[ \t]*' '/percentage/ {print $2}')
state=$(echo "$info" | awk -F':[ \t]*' '/state/ {print $2}')
time=$(echo "$info" | awk -F':[ \t]*' '/time to empty/ {print $2}')
[ -z "$time" ] && time=$(echo "$info" | awk -F':[ \t]*' '/time to full/ {print $2}')
[ -z "$time" ] && time="N/A"
energy=$(echo "$info" | awk -F':[ \t]*' '/energy:/ {print $2; exit}')
energy_full=$(echo "$info" | awk -F':[ \t]*' '/energy-full:/ {print $2; exit}')
voltage=$(echo "$info" | awk -F':[ \t]*' '/voltage:/ {print $2}' | sed 's/ V//')
temp=$(echo "$info" | awk -F':[ \t]*' '/temperature:/ {print $2}' | sed 's/ C//')

output="  State: $state"
[ -n "$percentage" ] && output="$output\n  Charge: $percentage"
[ -n "$time" ] && output="$output\n  Time: $time"
[ -n "$energy" ] && output="$output\n  Energy: $energy"
[ -n "$energy_full" ] && output="$output\n  Full: $energy_full"
[ -n "$voltage" ] && output="$output\n  Voltage: ${voltage}V"
[ -n "$temp" ] && output="$output\n  Temp: ${temp}°C"

printf '%b\n' "$output" | menu "Battery"
