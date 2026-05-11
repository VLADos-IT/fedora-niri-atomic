#!/bin/bash

get_profile() {
    tuned-adm active 2>/dev/null | awk '{print $4}'
}

set_profile() {
    local target="$1"

    case "$target" in

        performance)
            tuned-adm profile throughput-performance >/dev/null 2>&1
            ;;

        power-saver)
            tuned-adm profile powersave >/dev/null 2>&1
            ;;

    esac
}

normalize() {
    case "$1" in
        throughput-performance|latency-performance)
            echo "performance"
            ;;
        powersave)
            echo "power-saver"
            ;;
        *)
            echo "power-saver"
            ;;
    esac
}

CURRENT=$(normalize "$(get_profile)")


if [ "$1" = "toggle" ]; then
    case "$CURRENT" in
        performance)
            set_profile "power-saver"
            ;;
        power-saver|*)
            set_profile "performance"
            ;;
    esac
    exit 0
fi

case "$CURRENT" in

    performance)
        echo '{"text":"⚡","class":"performance","tooltip":"Performance (throughput-performance)"}'
        ;;

    power-saver)
        echo '{"text":"🔋","class":"battery","tooltip":"Power saver (powersave)"}'
        ;;

esac
