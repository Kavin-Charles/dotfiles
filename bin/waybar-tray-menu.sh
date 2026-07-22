#!/usr/bin/env bash
set -euo pipefail

declare -A SINK_MAP
declare -A NET_MAP
declare -A BT_MAP
declare -A BT_CONN
declare -A VPN_MAP

notify() {
    command -v notify-send >/dev/null && notify-send "$@"
}

entries=""

# Audio
entries+="─── Audio ───\n"
entries+="󰝟  Toggle Mute\n"
default_sink=$(pactl get-default-sink 2>/dev/null || true)
mapfile -t sinks < <(pactl list short sinks 2>/dev/null || true)
for s in "${sinks[@]}"; do
    IFS=$'\t' read -r id name driver _ <<< "$s"
    vol=$(pactl get-sink-volume "$name" 2>/dev/null | awk -F'/' 'NR==1{gsub(/ /,"",$2);print $2}' || echo "?")
    mute=$(pactl get-sink-mute "$name" 2>/dev/null | awk '{print $2}' || echo "no")
    icon="󰕾"
    case "$name" in *bluez*) icon="󰂯" ;; *hdmi*) icon="󰍹" ;; *headphone*|*headset*) icon="󰋋" ;; *speaker*) icon="󰓃" ;; esac
    [ "$mute" = "yes" ] && icon="󰝟"
    prefix="  "
    [ "$name" = "$default_sink" ] && prefix=" "
    label=$(sed -e 's/alsa_output\.//g' -e 's/bluez_output\.//g' -e 's/\.analog-stereo//g' -e 's/_/ /g' <<< "$name")
    entry="$prefix$icon  $label  ${vol:-?%}"
    entries+="$entry\n"
    SINK_MAP["$entry"]="$name"
done
entries+="  Open Pavucontrol\n"

# Wi-Fi
entries+="─── Network ───\n"
iface=$(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | awk -F: '$2=="wifi"{print $1;exit}' || true)
wifi_state=$(nmcli radio wifi 2>/dev/null || echo "unknown")
if [ "$wifi_state" = "disabled" ]; then
    entries+="󰖪  Turn Wi-Fi On\n"
else
    entries+="󰖩  Turn Wi-Fi Off\n"
    entries+="󰑐  Rescan Networks\n"
fi
if [ "$wifi_state" = "enabled" ] && [ -n "$iface" ]; then
    mapfile -t nets < <(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list ifname "$iface" 2>/dev/null | sort -t: -k3 -rn | head -10)
    for n in "${nets[@]}"; do
        IFS=: read -r inuse ssid signal sec <<< "$n"
        [ -z "$ssid" ] && continue
        if   ((signal>=80)); then icon2="󰤨"
        elif ((signal>=60)); then icon2="󰤥"
        elif ((signal>=40)); then icon2="󰤢"
        elif ((signal>=20)); then icon2="󰤟"
        else icon2="󰤯"
        fi
        prefix2="  "
        [ "$inuse" = "*" ] && prefix2=" "
        entry2="$prefix2$icon2  $signal%  $ssid"
        entries+="$entry2\n"
        NET_MAP["$entry2"]="$ssid"
    done
fi
entries+="󰈀  Open Network Manager\n"

# Bluetooth
entries+="─── Bluetooth ───\n"
powered=$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ {print $2}' || echo "no")
if [ "$powered" = "no" ]; then
    entries+="󰂲  Turn Bluetooth On\n"
else
    entries+="󰂯  Turn Bluetooth Off\n"
fi
mapfile -t bt_devices < <({
    bluetoothctl devices Connected 2>/dev/null
    bluetoothctl devices Paired 2>/dev/null
} | awk '!seen[$2]++')
for d in "${bt_devices[@]}"; do
    mac=${d#Device }
    mac=${mac%% *}
    name=${d#Device ??\:??\:??\:??\:??\:?? }
    [ -z "$name" ] && name="$mac"
    connected="no"
    bluetoothctl devices Connected 2>/dev/null | grep -q "$mac" && connected="yes"
    icon3="󰂲"
    prefix3="  "
    [ "$connected" = "yes" ] && icon3="󰂱" && prefix3=" "
    entry3="$prefix3$icon3  $name"
    [ "$connected" = "yes" ] && batt=$(bluetoothctl info "$mac" 2>/dev/null | sed -n 's/Battery.*(\([0-9]\+\))$/\1/p' | head -n1) && [ -n "$batt" ] && entry3+="  ${batt}%"
    entries+="$entry3\n"
    BT_MAP["$entry3"]="$mac"
    BT_CONN["$entry3"]="$connected"
done
entries+="󰂯  Open Bluetooth Manager\n"

# VPN
entries+="─── VPN ───\n"
while IFS= read -r conn; do
    name2="${conn%%:*}"
    [ -z "$name2" ] && continue
    active=$(nmcli -t -f NAME,ACTIVE connection show "$name2" 2>/dev/null | awk -F: 'NR==1{print $2}')
    prefix4="  "
    [ "$active" = "yes" ] && prefix4=" "
    entries+="$prefix4  $name2\n"
    VPN_MAP["$prefix4  $name2"]="$name2"
done < <(nmcli -t -f NAME,TYPE connection show 2>/dev/null | grep ':vpn\|:wireguard' | sed 's/:vpn$//;s/:wireguard$//')

# Battery
entries+="─── Battery ───\n"
bat_info=$(upower -i "$(upower -e 2>/dev/null | grep BAT)" 2>/dev/null || true)
if [ -n "$bat_info" ]; then
    percentage=$(echo "$bat_info" | awk -F':[ \t]*' '/percentage/ {print $2}')
    state=$(echo "$bat_info" | awk -F':[ \t]*' '/state/ {print $2}')
    time_bat=$(echo "$bat_info" | awk -F':[ \t]*' '/time to empty/ {print $2}')
    [ -z "$time_bat" ] && time_bat=$(echo "$bat_info" | awk -F':[ \t]*' '/time to full/ {print $2}')
    [ -z "$time_bat" ] && time_bat="N/A"
    entries+="  $percentage\n"
    entries+="  $time_bat\n"
    entries+="  $state\n"
else
    entries+="  No battery\n"
fi

# Clock
entries+="─── Clock ───\n"
entries+="  $(date '+%H:%M:%S')\n"
entries+="  $(date '+%A, %d %B %Y')\n"
entries+="$(cal 2>/dev/null | sed 's/^/   /')\n"

printf '%b\n' "$entries" > /tmp/waybar-menu.txt

choice=$(wofi --dmenu --prompt "System Tray" --width 500 --height 400 --conf /dev/null --style /dev/null < /tmp/waybar-menu.txt) || true
[ -z "$choice" ] && exit 0

# Audio actions
if [ "$choice" = "󰝟  Toggle Mute" ]; then
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    state=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
    [ "$state" = "yes" ] && notify "Audio" "Muted" || notify "Audio" "Unmuted"
    exit 0
fi

if [ "$choice" = "  Open Pavucontrol" ]; then
    pavucontrol >/dev/null 2>&1 &
    exit 0
fi

if [ "$choice" = "󰖪  Turn Wi-Fi On" ]; then
    nmcli radio wifi on && notify "Network" "Wi-Fi enabled"
    exit 0
fi

if [ "$choice" = "󰖩  Turn Wi-Fi Off" ]; then
    nmcli radio wifi off && notify "Network" "Wi-Fi disabled"
    exit 0
fi

if [ "$choice" = "󰑐  Rescan Networks" ]; then
    nmcli device wifi rescan >/dev/null 2>&1 && notify "Network" "Scanning..." || true
    exit 0
fi

if [ "$choice" = "󰈀  Open Network Manager" ]; then
    nm-connection-editor &
    exit 0
fi

net_ssid="${NET_MAP[$choice]:-}"
if [ -n "$net_ssid" ]; then
    if nmcli device wifi connect "$net_ssid" >/dev/null 2>&1; then
        notify "Network" "Connected to $net_ssid"
    else
        pass=$(wofi --dmenu --prompt "Password for $net_ssid" --width 520 --conf /dev/null --style /dev/null 2>/dev/null)
        [ -n "$pass" ] && nmcli device wifi connect "$net_ssid" password "$pass" >/dev/null 2>&1 && notify "Network" "Connected to $net_ssid" || notify "Network" "Connection failed"
    fi
    exit 0
fi

if [ "$choice" = "󰂲  Turn Bluetooth On" ]; then
    bluetoothctl power on >/dev/null && notify "Bluetooth" "Enabled"
    exit 0
fi

if [ "$choice" = "󰂯  Turn Bluetooth Off" ]; then
    bluetoothctl power off >/dev/null && notify "Bluetooth" "Disabled"
    exit 0
fi

if [ "$choice" = "󰂯  Open Bluetooth Manager" ]; then
    blueman-manager &
    exit 0
fi

bt_mac="${BT_MAP[$choice]:-}"
if [ -n "$bt_mac" ]; then
    bt_state="${BT_CONN[$choice]:-}"
    powered=$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ {print $2}' || echo "no")
    [ "$powered" = "no" ] && bluetoothctl power on >/dev/null
    if [ "$bt_state" = "yes" ]; then
        bluetoothctl disconnect "$bt_mac" >/dev/null && notify "Bluetooth" "Disconnected"
    else
        bluetoothctl connect "$bt_mac" >/dev/null && notify "Bluetooth" "Connected" || notify "Bluetooth" "Connection failed"
    fi
    exit 0
fi

vpn_name="${VPN_MAP[$choice]:-}"
if [ -n "$vpn_name" ]; then
    active=$(nmcli -t -f NAME,ACTIVE connection show "$vpn_name" 2>/dev/null | awk -F: 'NR==1{print $2}')
    if [ "$active" = "yes" ]; then
        nmcli connection down "$vpn_name" >/dev/null && notify "VPN" "$vpn_name disconnected"
    else
        nmcli connection up "$vpn_name" >/dev/null && notify "VPN" "$vpn_name connected" || notify "VPN" "Connection failed"
    fi
    exit 0
fi

sink="${SINK_MAP[$choice]:-}"
if [ -n "$sink" ]; then
    pactl set-default-sink "$sink"
    while read -r input _; do
        pactl move-sink-input "$input" "$sink"
    done < <(pactl list short sink-inputs 2>/dev/null)
    notify "Audio" "Switched output"
    exit 0
fi
