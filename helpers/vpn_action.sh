#!/bin/bash

ACTION=$1
VPN_NAME=$2
PLUGIN_NAME=$3

if [ "$ACTION" = "start" ]; then
    /usr/sbin/scutil --nc start "$VPN_NAME"
elif [ "$ACTION" = "stop" ]; then
    /usr/sbin/scutil --nc stop "$VPN_NAME"
else
    echo "Invalid action. Use 'start' or 'stop'."
    exit 1
fi

# VPN 상태 변경 후 약간의 대기 시간을 줍니다
sleep 2

# BitBar 플러그인 새로 고침
open "swiftbar://refreshplugin?name=$PLUGIN_NAME"