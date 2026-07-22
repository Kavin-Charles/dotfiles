#!/usr/bin/env bash
next=$(hyprctl workspaces -j | jq '[.[].id] | max // 0 | . + 1')
hyprctl dispatch "hl.dsp.focus({workspace=\"${next}\"})"
