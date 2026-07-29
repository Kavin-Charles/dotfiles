#!/usr/bin/env bash
vpn=$(nmcli -t -o connection show --active 2>/dev/null | grep -i vpn | head -1 | cut -d: -f1)
if [[ -n "$vpn" ]]; then
    echo ""
else
    echo ""
fi
