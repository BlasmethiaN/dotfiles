#!/usr/bin/env bash

generate_workspaces() {
    local monitor=$1

    local workspaces_json=$(hyprctl workspaces -j)
    local active_id=$(hyprctl monitors -j | jq --arg mon "$monitor" '.[] | select(.name == $mon) | .activeWorkspace.id')

    echo "$workspaces_json" | jq -c --argjson active "$active_id" --arg mon "$monitor" '
        [ .[] | select(.monitor == $mon) ] | sort_by(.id) |
        map({
            id: .id,
            active: (.id == $active),
            occupied: (.windows > 0)
        })'
}

monitor=$1
generate_workspaces "$monitor"

socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
    if [[ $line == "workspace>>"* || $line == "focusedmon>>"* || $line == "openwindow>>"* || $line == "closewindow>>"* || $line == "movewindow>>"* ]]; then
        generate_workspaces "$monitor"
    fi
done
