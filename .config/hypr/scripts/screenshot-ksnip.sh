#!/usr/bin/env bash
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

if ! SELECTION=$(slurp); then
  exit 1
fi

grim -g "$SELECTION" "$FILE"
wl-copy --type image/png < "$FILE"
notify-send "Screenshot saved" "$FILE"
