#!/bin/bash
PATH="/usr/bin:/bin:/usr/local/bin"
STATE_FILE="/tmp/hypr-show-desktop"
EMPTY_WS=9

echo "$(date) fired" >> /tmp/hypr-show-desktop.log

if [ -f "$STATE_FILE" ]; then
    echo "$(date) restoring" >> /tmp/hypr-show-desktop.log
    prev_ws=$(cat "$STATE_FILE")
    /usr/bin/hyprctl dispatch "hl.dsp.focus({workspace=\"$prev_ws\"})"
    rm -f "$STATE_FILE"
else
    echo "$(date) minimizing" >> /tmp/hypr-show-desktop.log
    cur_ws=$(/usr/bin/hyprctl activeworkspace -j | /usr/bin/jq -r '.id')
    echo "$cur_ws" > "$STATE_FILE"
    echo "$(date) curr ws = $cur_ws, switching to $EMPTY_WS" >> /tmp/hypr-show-desktop.log
    /usr/bin/hyprctl dispatch "hl.dsp.focus({workspace=\"$EMPTY_WS\"})"
fi
echo "$(date) done" >> /tmp/hypr-show-desktop.log
