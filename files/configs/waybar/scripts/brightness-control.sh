#!/bin/bash
MIN_BRIGHTNESS=1
MAX_BRIGHTNESS=100

FACTOR_UP=1.25
FACTOR_DOWN=0.80


LOW_BRIGHTNESS_THRESHOLD=12

SMOOTH_STEPS=14
SMOOTH_DELAY=0.006

get_brightness_percent() {
    local percent

    percent=$(brightnessctl -m | awk -F',' '
        {
            gsub(/%/, "", $4)
            print int($4)
        }
    ')

    if [ "$percent" -lt "$MIN_BRIGHTNESS" ]; then
        percent=$MIN_BRIGHTNESS
    fi

    echo "$percent"
}

clamp() {
    local value=$1

    if [ "$value" -lt "$MIN_BRIGHTNESS" ]; then
        value=$MIN_BRIGHTNESS
    fi

    if [ "$value" -gt "$MAX_BRIGHTNESS" ]; then
        value=$MAX_BRIGHTNESS
    fi

    echo "$value"
}

status() {
    local percent
    percent=$(get_brightness_percent)

    echo "{\"text\": \" ${percent}%\", \"tooltip\": \"Brightness: ${percent}%\"}"
}

smooth_set() {
    local target
    target=$(clamp "$1")

    local current
    current=$(get_brightness_percent)

    if [ "$current" -eq "$target" ]; then
        return
    fi

    if [ "$current" -le "$LOW_BRIGHTNESS_THRESHOLD" ] || \
       [ "$target" -le "$LOW_BRIGHTNESS_THRESHOLD" ]; then

        brightnessctl set "${target}%" >/dev/null
        return
    fi

    local diff=$((target - current))

    for ((i=1; i<=SMOOTH_STEPS; i++)); do

        local value
        value=$(
            awk \
                -v c="$current" \
                -v d="$diff" \
                -v i="$i" \
                -v s="$SMOOTH_STEPS" \
                'BEGIN {
                    printf "%.0f", c + (d * i / s)
                }'
        )

        value=$(clamp "$value")

        brightnessctl set "${value}%" >/dev/null

        sleep "$SMOOTH_DELAY"
    done

    brightnessctl set "${target}%" >/dev/null
}

up() {
    local current
    local target

    current=$(get_brightness_percent)

    if [ "$current" -lt "$LOW_BRIGHTNESS_THRESHOLD" ]; then

        target=$((current + 1))

    else

        target=$(
            awk \
                -v c="$current" \
                -v f="$FACTOR_UP" \
                'BEGIN {
                    printf "%.0f", c * f
                }'
        )

        if [ "$target" -le "$current" ]; then
            target=$((current + 1))
        fi
    fi

    smooth_set "$target"
}

down() {
    local current
    local target

    current=$(get_brightness_percent)

    if [ "$current" -le "$LOW_BRIGHTNESS_THRESHOLD" ]; then

        target=$((current - 1))

    else

        target=$(
            awk \
                -v c="$current" \
                -v f="$FACTOR_DOWN" \
                'BEGIN {
                    printf "%.0f", c * f
                }'
        )

        if [ "$target" -ge "$current" ]; then
            target=$((current - 1))
        fi
    fi

    smooth_set "$target"
}

toggle() {
    local current
    current=$(get_brightness_percent)

    if [ "$current" -le "$MIN_BRIGHTNESS" ]; then
        smooth_set 50
    else
        smooth_set "$MIN_BRIGHTNESS"
    fi
}

case "$1" in
    status)
        status
        ;;

    up)
        up
        ;;

    down)
        down
        ;;

    toggle)
        toggle
        ;;

    *)
        status
        ;;
esac
