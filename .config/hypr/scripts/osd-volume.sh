#!/bin/bash
# Volume OSD using dunst with progress bar
case "$1" in
  up)   pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
  down) pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
  mute) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
esac

vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%')
muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o 'yes')
[ "$muted" = "yes" ] && vol=0

icon="󰕾"
[ "$vol" -eq 0 ] && icon="󰝟"
[ "$vol" -lt 34 ] && icon="󰕿"
[ "$vol" -ge 34 ] && [ "$vol" -lt 68 ] && icon="󰖀"

notify-send -a "OSD" -r 9999 -u normal \
  -h int:value:"$vol" \
  -h string:x-canonical-private-synchronous:volume \
  "$icon  Volume" "${vol}%"
