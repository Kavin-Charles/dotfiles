#!/bin/bash
case "$1" in
  up)   pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
  down) pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
  mute) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
esac
vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%')
[ "$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o 'yes')" = "yes" ] && vol=0
echo "volume $vol" > /tmp/ags-osd
