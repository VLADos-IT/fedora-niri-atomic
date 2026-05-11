#!/bin/bash

CACHE_FILE="/tmp/waybar-temp-sensor"
LAST_TEMP_FILE="/tmp/waybar-temp-last"

read_cpu_sensor() {
    local best_zone=""
    local best_temp=0

    for zone in /sys/class/thermal/thermal_zone*; do
        [ -r "$zone/temp" ] || continue
        [ -r "$zone/type" ] || continue

        local type temp
        type=$(cat "$zone/type")
        temp=$(cat "$zone/temp")

        if [ "$temp" -lt 15000 ] || [ "$temp" -gt 120000 ]; then
            continue
        fi

        if echo "$type" | grep -Eiq 'cpu|package|pkg|x86_pkg_temp|k10temp|tctl|soc'; then
            if [ "$temp" -gt "$best_temp" ]; then
                best_temp="$temp"
                best_zone="$zone"
            fi
        fi
    done

    # fallback
    if [ -z "$best_zone" ]; then
        for zone in /sys/class/thermal/thermal_zone*; do
            [ -r "$zone/temp" ] || continue

            local temp
            temp=$(cat "$zone/temp")

            if [ "$temp" -lt 15000 ] || [ "$temp" -gt 120000 ]; then
                continue
            fi

            if [ "$temp" -gt "$best_temp" ]; then
                best_temp="$temp"
                best_zone="$zone"
            fi
        done
    fi

    if [ -n "$best_zone" ]; then
        echo "$best_zone" > "$CACHE_FILE"
    else
        best_zone=$(cat "$CACHE_FILE" 2>/dev/null)
    fi

    echo "$best_zone"
}

status() {
    local zone temp ctemp last_temp icon class

    zone=$(read_cpu_sensor)

    if [ -z "$zone" ] || [ ! -r "$zone/temp" ]; then
        echo '{"text":"󰔅 N/A","class":"unknown","tooltip":"Temperature unavailable"}'
        exit 0
    fi

    temp=$(cat "$zone/temp")
    ctemp=$((temp / 1000))


    last_temp=$(cat "$LAST_TEMP_FILE" 2>/dev/null)

    if [ -n "$last_temp" ]; then
        diff=$((ctemp - last_temp))

        if [ "${diff#-}" -gt 25 ]; then
            ctemp=$last_temp
        fi
    fi

    echo "$ctemp" > "$LAST_TEMP_FILE"


    if [ "$ctemp" -ge 85 ]; then
        icon="󰸁"
        class="hot"
    elif [ "$ctemp" -ge 65 ]; then
        icon="󱃃"
        class="warm"
    elif [ "$ctemp" -ge 45 ]; then
        icon="󰈐"
        class="normal"
    else
        icon="󰈐"
        class="cool"
    fi

    printf '{"text":"%s %d°C","class":"%s","tooltip":"CPU temp: %d°C"}\n' \
        "$icon" "$ctemp" "$class" "$ctemp"
}

status
