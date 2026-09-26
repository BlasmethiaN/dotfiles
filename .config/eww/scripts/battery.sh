#!/usr/bin/env bash
set -euo pipefail

shopt -s nullglob
batteries=(/sys/class/power_supply/BAT*)

if ((${#batteries[@]} == 0)); then
    printf '{"present":false,"capacity":0,"status":"Unknown"}\n'
    exit 0
fi

battery=${batteries[0]}
if [[ ! -r "$battery/capacity" || ! -r "$battery/status" ]]; then
    printf '{"present":false,"capacity":0,"status":"Unknown"}\n'
    exit 0
fi

capacity=$(<"$battery/capacity")
status=$(<"$battery/status")
if [[ ! $capacity =~ ^[0-9]+$ ]]; then
    capacity=0
fi

printf '{"present":true,"capacity":%s,"status":"%s"}\n' "$capacity" "$status"
