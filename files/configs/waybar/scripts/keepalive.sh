#!/bin/bash

STATE_FILE="$HOME/.cache/waybar-keepalive"
INHIBIT_PID_FILE="$HOME/.cache/waybar-keepalive.pid"

toggle() {
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
        if [ -f "$INHIBIT_PID_FILE" ]; then
            kill $(cat "$INHIBIT_PID_FILE") 2>/dev/null
            rm -f "$INHIBIT_PID_FILE"
        fi
    else
        mkdir -p "$HOME/.cache"
        touch "$STATE_FILE"
        
        systemd-inhibit --why="User enabled keep-alive" --who="Waybar" sleep infinity &
        echo $! > "$INHIBIT_PID_FILE"
    fi
}

get_status() {
    if [ -f "$STATE_FILE" ]; then
        echo "{\"text\": \"󰒲\", \"class\": \"active\", \"tooltip\": \"Keep-Alive: ON\"}"
    else
        echo "{\"text\": \"󰒳\", \"class\": \"inactive\", \"tooltip\": \"Keep-Alive: OFF\"}"
    fi
}

case "$1" in
    toggle)
        toggle
        get_status
        ;;
    *)
        get_status
        ;;
esac
