#!/usr/bin/env bash

get_vol() {
    pamixer --get-volume
}

get_vol

pactl subscribe | stdbuf -oL grep "sink" | while read -r line; do
    get_vol
done
