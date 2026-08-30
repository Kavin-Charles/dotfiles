#!/bin/bash
WOB_PIPE="/tmp/wob-brightness"

case "$1" in
  up)   brightnessctl -e4 -n2 set 5%+ ;;
  down) brightnessctl -e4 -n2 set 5%- ;;
esac

max=$(brightnessctl max)
cur=$(brightnessctl get)
pct=$(( cur * 100 / max ))

if [ ! -p "$WOB_PIPE" ]; then
    mkfifo "$WOB_PIPE"
fi

echo "$pct" > "$WOB_PIPE"
