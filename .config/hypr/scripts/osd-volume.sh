#!/bin/bash
WOB_PIPE="/tmp/wob-volume"

case "$1" in
  up)   pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
  down) pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
  mute) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
esac

vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%')
muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o 'yes')
[ "$muted" = "yes" ] && vol=0

if [ ! -p "$WOB_PIPE" ]; then
    mkfifo "$WOB_PIPE"
fi

echo "$vol" > "$WOB_PIPE"
