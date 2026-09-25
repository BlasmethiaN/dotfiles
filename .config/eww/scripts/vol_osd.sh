#!/usr/bin/env bash

if [ "$1" == "up" ]; then
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
elif [ "$1" == "down" ]; then
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
elif [ "$1" == "mute" ]; then
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
fi
