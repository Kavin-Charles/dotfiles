#!/usr/bin/env bash
current=$(hyprctl activeworkspace -j | jq '.id')
prev=$((current - 1))
[ "$prev" -lt 1 ] && prev=1
hyprctl dispatch "hl.dsp.window.move({workspace=\"${prev}\"})"
hyprctl dispatch "hl.dsp.focus({workspace=\"${prev}\"})"
