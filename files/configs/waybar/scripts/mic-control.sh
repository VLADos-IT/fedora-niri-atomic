#!/bin/bash

SOURCE="@DEFAULT_AUDIO_SOURCE@"

case "$1" in
    up)
        wpctl set-volume -l 1.0 "$SOURCE" 5%+
        pkill -RTMIN+2 waybar
        ;;
    down)
        wpctl set-volume "$SOURCE" 5%-
        pkill -RTMIN+2 waybar
        ;;
    toggle)
        wpctl set-mute "$SOURCE" toggle
        pkill -RTMIN+2 waybar
        ;;
    status)
        wpctl get-volume "$SOURCE" | awk '
        BEGIN {muted=0}
        /\[MUTED\]/ {muted=1}
        {
            v = $2 * 100
            if (v > 100) v = 100
            
            if (muted || v == 0) { icon = "󰍭"; alt = "muted"; class = "muted" }
            else { icon = "󰍬"; alt = "unmuted"; class = "unmuted" }
            
            printf "{\"text\": \"%s %d%%\", \"alt\": \"%s\", \"class\": \"%s\", \"tooltip\": \"Mic: %d%%\"}\n",
                icon, int(v), alt, class, int(v)
        }'
        ;;
esac
