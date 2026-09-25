#!/usr/bin/env bash

CON=$(nmcli -t -f TYPE,NAME connection show --active | head -n 1)

if [[ -z "$CON" ]]; then
    echo "Disconnected"
elif [[ "$CON" == *"ethernet"* ]]; then
    echo "Wired"
else
    echo "$CON" | cut -d: -f2
fi
