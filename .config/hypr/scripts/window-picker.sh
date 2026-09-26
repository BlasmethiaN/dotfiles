#!/usr/bin/env bash
set -euo pipefail

if selection=$(hyprctl clients -j \
  | jq -r '.[] | [.address, (.class // "unknown"), (.title // "untitled")] | @tsv' \
  | fuzzel --dmenu --prompt="WINDOW: "); then
  :
else
  status=$?
  if ((status == 1)); then
    exit 0
  fi
  exit "$status"
fi

[[ -n "$selection" ]] || exit 0
hyprctl dispatch focuswindow "address:${selection%%$'\t'*}"
