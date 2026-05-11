#!/bin/bash

VPN_NAME="" # Set your VPN connection name here 

get_vpn_status() {
    if nmcli connection show --active | grep -q "$VPN_NAME"; then
        echo "connected"
    else
        echo "disconnected"
    fi
}

toggle_vpn() {
    local status=$(get_vpn_status)
    if [ "$status" == "connected" ]; then
        nmcli connection down "$VPN_NAME"
    else
        nmcli connection up "$VPN_NAME"
    fi
}

status() {
    if [ "$(get_vpn_status)" == "connected" ]; then
        echo "{\"text\": \"🔒\", \"tooltip\": \"VPN: Connected\", \"class\": \"connected\"}"
    else
        echo "{\"text\": \"🔓\", \"tooltip\": \"VPN: Disconnected\", \"class\": \"disconnected\"}"
    fi
}

case "$1" in
    toggle) toggle_vpn && status ;;
    *) status ;;
esac
