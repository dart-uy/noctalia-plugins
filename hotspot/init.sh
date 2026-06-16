#!/bin/bash

# Script used to check wifi device and hotspot connection.
# It sends exit codes that noctalia hotspot plugin will evaluate

set -e

DEVICE=$1
SSID=$2
PSK=$3
SEC=$4
BAND=$5
CHANNEL=$6
CHANNELWIDTH=$7

function create_connection {
    nmcli device wifi hotspot ifname $DEVICE con-name Hotspot 2>/dev/null

    if [ $? != 0 ]; then
        exit 2
    fi
}

AP_CAP=$(nmcli -g WIFI-PROPERTIES.AP device show $DEVICE)

if [ -z $AP_CAP ]; then
    exit 1
fi

connection_state=$(nmcli -g GENERAL.STATE connection show Hotspot 2>/dev/null)

# connection does not exist
if [ $? != 0 ]; then
    create_connection
fi

nmcli connection modify Hotspot \
    802-11-wireless.ssid $SSID \
    802-11-wireless-security.key-mgmt $SEC \
    802-11-wireless-security.psk $PSK \
    802-11-wireless.band $BAND \
    802-11-wireless.channel $CHANNEL \
    802-11-wireless.channel-width $CHANNELWIDTH \
    &>/dev/null

# Check if Hotspot is on, variable must be unset if awk filter returns nothing
if [ -v $connection_state ]; then
    exit 3
else
    # With changes made above, hotspot need to be restarted to take effect
    nmcli connection down Hotspot &>/dev/null && nmcli connection up Hotspot &>/dev/null
fi
