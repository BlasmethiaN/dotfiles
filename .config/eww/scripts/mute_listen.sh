#!/usr/bin/env bash

get_mute() {
    pamixer --get-mute
}

get_mute

pactl subscribe | while read -r line; do
    if echo "$line" | grep -q "sink"; then
        get_mute
    fi
done
