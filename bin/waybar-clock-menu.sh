#!/usr/bin/env bash
set -euo pipefail

menu() {
    wofi --dmenu --insensitive --prompt "$1" --matching fuzzy --width 400 --lines 12 --cache-file /dev/null
}

output="$(date '+  %H:%M:%S')\n$(date '+  %A, %d %B %Y')\n\n$(cal -3)"
printf '%b\n' "$output" | menu "Clock"
