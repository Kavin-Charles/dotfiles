#!/usr/bin/env bash
set -euo pipefail

menu() {
    read -r x y < <(hyprctl cursorpos | tr , ' ')
    read -r w < <(hyprctl monitors -j | jq -r '.[] | select(.focused).width' 2>/dev/null || echo 1920)
    x=$(( x + 10 > w - 400 ? w - 410 : x < 10 ? 10 : x + 10 ))
    wofi --dmenu --insensitive --prompt "$1" --matching fuzzy --width 400 --cache-file /dev/null --location 0 --xoffset "$x" --yoffset 30
}

notify() {
    command -v notify-send >/dev/null && notify-send "Spotify" "$1"
}

while true; do
status=$(playerctl -p spotify status 2>/dev/null) || status="Stopped"
metadata=$(playerctl -p spotify metadata --format '{{ artist }} — {{ title }}' 2>/dev/null) || metadata="No track"

playpause="  Play/Pause"
[ "$status" = "Playing" ] && playpause="  Play/Pause"
next="  Next"
prev="  Previous"
info="  Now Playing: $metadata"

entries="$info\n\n$playpause\n$next\n$prev"

choice=$(printf '%b\n' "$entries" | menu "Spotify")
[ -z "$choice" ] && exit 0

case "$choice" in
    "$playpause") playerctl -p spotify play-pause && exit 0 ;;
    "$next") playerctl -p spotify next && exit 0 ;;
    "$prev") playerctl -p spotify previous && exit 0 ;;
esac
done
