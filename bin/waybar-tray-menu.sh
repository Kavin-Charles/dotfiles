#!/usr/bin/env bash
set -euo pipefail

qs -c tray ipc call tray ping &>/dev/null || {
  qs -c tray &>/dev/null &
  sleep 2
}

qs -c tray ipc call tray toggle
