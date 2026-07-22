#!/usr/bin/env bash
set -euo pipefail

menu() {
    wofi --dmenu --insensitive --prompt "$1" --matching fuzzy --width 400 --lines 8 --cache-file /dev/null
}

info=$(upower -i $(upower -e | grep BAT) 2>/dev/null)
[ -z "$info" ] && { notify-send "Battery" "No battery found"; exit 1; }

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
