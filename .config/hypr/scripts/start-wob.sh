#!/bin/bash
# Kill any existing wob processes
killall tail 2>/dev/null
killall wob 2>/dev/null
sleep 0.5
rm -f /tmp/wob-volume /tmp/wob-brightness

# Create FIFOs
mkfifo /tmp/wob-volume
mkfifo /tmp/wob-brightness

# Start wob daemons
nohup tail -f /tmp/wob-volume | wob --config "$HOME/.config/wob/wob.ini" >/dev/null 2>&1 &
nohup tail -f /tmp/wob-brightness | wob --config "$HOME/.config/wob/wob.ini" >/dev/null 2>&1 &
disown
