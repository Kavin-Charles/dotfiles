#!/usr/bin/env bash
set -euo pipefail

menu() {
    read -r x y < <(hyprctl cursorpos | tr , ' ')
    read -r w < <(hyprctl monitors -j | jq -r '.[] | select(.focused).width' 2>/dev/null || echo 1920)
    x=$(( x + 10 > w - 520 ? w - 530 : x < 10 ? 10 : x + 10 ))
    wofi --dmenu --insensitive --prompt "$1" --matching fuzzy --width 520 --cache-file /dev/null --location 0 --xoffset "$x" --yoffset 30
}

notify() {
    command -v notify-send >/dev/null && notify-send "VPN" "$1"
}

while true; do
mapfile -t connections < <(nmcli -t -f NAME,TYPE,ACTIVE connection show | grep ':vpn\|:wireguard' | sed 's/:vpn$//;s/:wireguard$//')
entries=""
declare -A conn_map

for conn in "${connections[@]}"; do
    name="${conn%:*}"
    active="${conn##*:}"
    [ -z "$active" ] && active="no"
    icon="󰖂"
    prefix="  "
    if [ "$active" = "yes" ]; then
        icon=""
        prefix=" "
    fi
    entry="$prefix$icon  $name"
    entries="$entries\n$entry"
    conn_map["$entry"]="$name:$active"
done

[ -z "$entries" ] && { notify "No VPN connections found"; exit 1; }

choice=$(printf '%b\n' "$entries" | menu "VPN")
[ -z "$choice" ] && exit 0

data="${conn_map[$choice]:-}"
[ -z "$data" ] && continue

name="${data%:*}"
active="${data##*:}"

if [ "$active" = "yes" ]; then
    nmcli connection down "$name" && notify "VPN $name disconnected"
else
    nmcli connection up "$name" && notify "VPN $name connected"
fi
done
