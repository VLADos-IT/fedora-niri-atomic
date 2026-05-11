#!/bin/sh

layout=$(localectl status 2>/dev/null | awk -F: '/X11 Layout/ { gsub(/^[ \t]+/, "", $2); print $2 }')

if [ -n "$layout" ]; then
    printf 'keyboard layout: %s\n' "$layout"
fi

exit 0
