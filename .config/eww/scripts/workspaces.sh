#!/usr/bin/env bash
set -euo pipefail

generate_workspaces() {
    local monitor_id=$1
    local monitors_json monitor active_id workspaces_json

    monitors_json=$(hyprctl monitors -j)
    monitor=$(jq -r --argjson id "$monitor_id" '[.[] | select(.id == $id) | .name][0] // empty' <<<"$monitors_json")
    if [[ -z "$monitor" ]]; then
        printf '[]\n'
        return
    fi

    active_id=$(jq -r --arg mon "$monitor" '[.[] | select(.name == $mon) | .activeWorkspace.id][0] // -1' <<<"$monitors_json")
    workspaces_json=$(hyprctl workspaces -j)

    jq -c --argjson active "$active_id" --arg mon "$monitor" '
        [ .[] | select(.monitor == $mon) ] | sort_by(.id) |
        map({
            id: .id,
            active: (.id == $active),
            occupied: (.windows > 0)
        })' <<<"$workspaces_json"
}

monitor_id=${1:?Monitor ID is required}
generate_workspaces "$monitor_id"

socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
    if [[ $line == "workspace>>"* || $line == "focusedmon>>"* || $line == "openwindow>>"* || $line == "closewindow>>"* || $line == "movewindow>>"* || $line == "monitoradded>>"* || $line == "monitorremoved>>"* ]]; then
        generate_workspaces "$monitor_id"
    fi
done
