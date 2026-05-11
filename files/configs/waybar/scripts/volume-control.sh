#!/bin/bash

SINK="@DEFAULT_AUDIO_SINK@"

refresh() {
    sleep 0.05
    pkill -RTMIN+1 waybar
}

get_volume() {
    wpctl get-volume "$SINK"
}

is_muted() {
    get_volume | grep -q "\[MUTED\]"
}

case "$1" in

    up)
        if is_muted; then
            wpctl set-mute "$SINK" 0
        fi

        wpctl set-volume -l 1.0 "$SINK" 3%+

        refresh
        ;;

    down)
        wpctl set-volume "$SINK" 3%-

        refresh
        ;;

    toggle)
        if is_muted; then
            wpctl set-mute "$SINK" 0
        else
            wpctl set-mute "$SINK" 1
        fi

        refresh
        ;;

    status)

        get_volume | awk '

        BEGIN {
            muted = 0
        }

        /\[MUTED\]/ {
            muted = 1
        }

        {
            v = int($2 * 100)

            if (v < 0) v = 0
            if (v > 100) v = 100

            if (muted) {

                icon = "󰝟"
                alt = "muted"
                class = "muted"

            }

            else if (v == 0) {

                icon = "󰕿"
                alt = "zero"
                class = "zero"

            }

            else if (v < 33) {

                icon = "󰕿"
                alt = "low"
                class = "low"

            }

            else if (v < 66) {

                icon = "󰖀"
                alt = "medium"
                class = "medium"

            }

            else {

                icon = "󰕾"
                alt = "high"
                class = "high"
            }

            printf "{\"text\":\"%s %d%%\",\"alt\":\"%s\",\"class\":\"%s\",\"tooltip\":\"Volume: %d%%\"}\n",
                icon, v, alt, class, v
        }'
        ;;
esac
