#!/usr/bin/env bash
set -euo pipefail

menu() {
    read -r x y < <(hyprctl cursorpos | tr , ' ')
    read -r w < <(hyprctl monitors -j | jq -r '.[] | select(.focused).width' 2>/dev/null || echo 1920)
    x=$(( x + 10 > w - 400 ? w - 410 : x < 10 ? 10 : x + 10 ))
    wofi --dmenu --insensitive --prompt "$1" --matching fuzzy --width 400 --lines 12 --cache-file /dev/null --location 0 --xoffset "$x" --yoffset 30
}

output="$(date '+  %H:%M:%S')\n$(date '+  %A, %d %B %Y')\n\n$(cal -3)"
printf '%b\n' "$output" | menu "Clock"
