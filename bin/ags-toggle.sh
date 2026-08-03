#!/usr/bin/env bash
set -euo pipefail

target="$1"
state_file="/tmp/ags-drawer-open"
lock_file="/tmp/ags-drawer-lock"

# Lock to prevent auto-close from racing with this toggle
touch "$lock_file"

current=$(cat "$state_file" 2>/dev/null || echo "")

if [ "$current" = "$target" ]; then
  rm -f "$state_file"
else
  [ -n "$current" ] && ags toggle "$current" >/dev/null 2>&1 || true
  echo "$target" > "$state_file"
fi

ags toggle "$target" >/dev/null 2>&1 || true

# Keep lock briefly to ensure auto-close sees it
(sleep 0.3; rm -f "$lock_file") &
