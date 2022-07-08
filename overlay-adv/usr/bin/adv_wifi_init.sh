#!/bin/bash

# HACK: Prevent blueman from changing rfkill states
rm /dev/rfkill

# init BT Power
if [ -f /sys/class/rfkill/rfkill0/state ];then
    BT_POWER=`cat /sys/class/rfkill/rfkill0/state`
    echo BT_POWER:$BT_POWER
    if [ $BT_POWER -eq 0 ];then
        echo "BT_POWER is OFF"
        echo 1 > /sys/class/rfkill/rfkill0/state
        sleep 6
    else
        echo "BT_POWER is Already On"
    fi
fi

# init wifi
rk_wifi_init /dev/ttyS0

