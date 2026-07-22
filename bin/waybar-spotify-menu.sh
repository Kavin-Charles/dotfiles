#!/usr/bin/env bash
set -euo pipefail

menu() {
    wofi --dmenu --insensitive --prompt "$1" --matching fuzzy --width 400 --cache-file /dev/null
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
