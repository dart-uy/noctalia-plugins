#!/bin/bash

# Script used to check wifi device and hotspot connection.
# It sends exit codes that noctalia hotspot plugin will evaluate

set -e

readonly device=$1
readonly ssid=$2
readonly password=$3
readonly security=$4

readonly band=$5
readonly channel=$6
readonly channel_width=$7

function create_connection {
    nmcli device wifi hotspot ifname $device con-name Hotspot 2>/dev/null

    if [ $? != 0 ]; then
        exit 2
    fi
}

AP_CAP=$(nmcli -f WIFI-PROPERTIES.AP device show $device | awk '{ print $2 }')

if [ -z $AP_CAP ]; then
    exit 1
fi

connection_state=$(nmcli connection show Hotspot 2>/dev/null | awk '/GENERAL.STATE/ { print $2 }')

# connection does not exist
if [ $? != 0 ]; then
    create_connection
fi

nmcli connection modify Hotspot \
    802-11-wireless.ssid $ssid \
    802-11-wireless-security.key-mgmt $security \
    802-11-wireless-security.psk $password \
    802-11-wireless.band $band \
    802-11-wireless.channel $channel \
    802-11-wireless.channel-width $channel_width \
    &>/dev/null

# Check if Hotspot is on, variable must be unset if awk filter returns nothing
if [ -v $connection_state ]; then
    exit 3
else
    # With changes made above, hotspot need to be restarted to take effect
    nmcli connection down Hotspot &>/dev/null && nmcli connection up Hotspot &>/dev/null
fi
