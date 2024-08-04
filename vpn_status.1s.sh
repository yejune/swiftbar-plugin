#!/bin/bash
# <bitbar.title>VPN Connector</bitbar.title>
# <bitbar.version>v1.8</bitbar.version>
# <bitbar.author>Yejune</bitbar.author>
# <bitbar.author.github>yejune</bitbar.author.github>
# <bitbar.desc>VPN Name and Connection Time with Internet Check and Control</bitbar.desc>
# <bitbar.dependencies>bash</bitbar.dependencies>

TEMP_DIR="/tmp/vpn_connect_times"
mkdir -p "$TEMP_DIR"

get_elapsed_time() {
    local start_time=$1
    local current_time=$(date +%s)
    local elapsed_seconds=$((current_time - start_time))
    date -u -r "$elapsed_seconds" +"%H:%M:%S"
}

check_internet() {
    ping -c 1 8.8.8.8 &>/dev/null
    return $?
}

CURRENT_PLUGIN_NAME=$(basename "$SWIFTBAR_PLUGIN_PATH")

# Get all VPN connections
VPN_LIST=$(/usr/sbin/scutil --nc list | grep -E '^\*.*IPSec')

# Check if any VPN is connected
CONNECTED_VPN=$(echo "$VPN_LIST" | grep 'Connected')

if [ -n "$CONNECTED_VPN" ]; then
    VPN_ID=$(echo "$CONNECTED_VPN" | awk '{print $3}')
    VPN_NAME=$(echo "$CONNECTED_VPN" | sed -E 's/.*"(.*)".*/\1/')
    TEMP_FILE="$TEMP_DIR/${VPN_ID}.txt"

    # Get or set connection time
    if [ -f "$TEMP_FILE" ]; then
        CONNECT_TIME=$(cat "$TEMP_FILE")
    else
        CONNECT_TIME=$(date +%s)
        echo "$CONNECT_TIME" > "$TEMP_FILE"
    fi

    ELAPSED_TIME=$(get_elapsed_time "$CONNECT_TIME")

    if check_internet; then
        echo ":lock.shield:$VPN_NAME($ELAPSED_TIME) | color=red sfcolor=red sfsize=16 xfont=D2coding"
        echo "---"
        echo "Connected for: $ELAPSED_TIME"
    else
        echo ":lock.shield:$VPN_NAME (!) | color=orange sfcolor=orange sfsize=16 xfont=D2coding"
        echo "---"
        echo "Connected for: $ELAPSED_TIME (No Internet)"
    fi
    echo "Disconnect | bash=/usr/sbin/scutil param1=--nc param2=stop param3=\"$VPN_NAME\" terminal=false refresh=true"
else
    echo "Disconnected | color=gray"
    # Remove all temp files when no VPN is connected
    rm -f "$TEMP_DIR"/*.txt
fi

echo "---"
echo "VPN Status:"
echo "$VPN_LIST" | while read -r line; do
    STATUS=$(echo "$line" | awk '{print $2}' | tr -d '()')
    NAME=$(echo "$line" | sed -E 's/.*"(.*)".*/\1/')
    if [ "$STATUS" = "Connected" ]; then
        if check_internet; then
            echo "$NAME: $STATUS | color=red"
        else
            echo "$NAME: $STATUS (No Internet) | color=orange"
        fi
        echo "-- Disconnect | bash=$HOME/.SwiftBar/helpers/vpn_action.sh param1=stop param2=\"$NAME\" param3=\"$CURRENT_PLUGIN_NAME\" terminal=true"
    else
        echo "$NAME: $STATUS"
        echo "-- Connect | bash=$HOME/.SwiftBar/helpers/vpn_action.sh param1=start param2=\"$NAME\"  param3=\"$CURRENT_PLUGIN_NAME\" terminal=true"
    fi
done

echo "---"
echo "Refresh | refresh=true"
# echo "List Network Services | bash=$HOME/.SwiftBar/vpn_list.sh terminal=true"