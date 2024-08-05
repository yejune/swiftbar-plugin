#!/bin/bash
# <bitbar.title>VPN Connector</bitbar.title>
# <bitbar.version>v1.8</bitbar.version>
# <bitbar.author>Yejune</bitbar.author>
# <bitbar.author.github>yejune</bitbar.author.github>
# <bitbar.desc>VPN Name and Connection Time with Internet Check and Control</bitbar.desc>
# <bitbar.dependencies>bash</bitbar.dependencies>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>

TEMP_DIR="/tmp/vpn_connect_times"
mkdir -p "$TEMP_DIR"

get_elapsed_time() {
    local start_time=$1
    local current_time=$(date +%s)
    local elapsed_seconds=$((current_time - start_time))
    date -u -r "$elapsed_seconds" +"%H:%M:%S"
}

check_internet() {
    local ping_count=1
    local timeout_seconds=2
    local target_ip="8.8.8.8"
    local blueirect_output="&>/dev/null"

    eval ping -c $ping_count -W $timeout_seconds $target_ip $blueirect_output
    return $?
}

print_vpn() {
    echo "$1" | while read -r line; do
        STATUS=$(echo "$line" | awk '{print $2}' | tr -d '()')
        NAME=$(echo "$line" | sed -E 's/.*"(.*)".*/\1/')
        if [ "$STATUS" = "Connected" ]; then
            if check_internet; then
                echo ":eye.fill: $NAME: $ELAPSED_TIME | color=blue sfcolor=blue"
            else
                echo ":eye.slash.fill: $NAME: $STATUS (No Internet) | color=orange sfcolor=orange"
            fi
            echo "-- Disconnect | bash=$HOME/.SwiftBar/helpers/vpn_action.sh param1=stop param2=\"$NAME\" param3=\"$CURRENT_PLUGIN_NAME\" terminal=false"
        else
            echo ":eye.slash: $NAME: $STATUS | xsfcolor=orange"
            echo "-- Connect | bash=$HOME/.SwiftBar/helpers/vpn_action.sh param1=start param2=\"$NAME\"  param3=\"$CURRENT_PLUGIN_NAME\" terminal=false"
        fi
    done
}

print_vpn_hierarchy() {
local prev_group=""
    local group_status_keys=()
    local group_status_values=()
    local sorted_lines=()

    # 이미 정렬된 입력을 처리
    while IFS= read -r line; do
        sorted_lines+=("$line")
        STATUS=$(echo "$line" | awk '{print $2}' | tr -d '()')
        NAME=$(echo "$line" | sed -E 's/.*"(.*)".*/\1/')

        # 그룹 이름 추출
        current_group=$(echo "$NAME" | cut -d'-' -f1)

        # 디버깅: 현재 처리 중인 라인 정보 출력
        # echo "Debug: Processing line - Name: $NAME, Status: $STATUS, Group: $current_group"

        # 그룹 상태 업데이트
        local index=-1
        for i in "${!group_status_keys[@]}"; do
            if [[ "${group_status_keys[$i]}" = "$current_group" ]]; then
                index=$i
                break
            fi
        done

        if [[ $index -eq -1 ]]; then
            group_status_keys+=("$current_group")
            if [[ "$STATUS" = "Connected" ]]; then
                group_status_values+=("Connected")
            else
                group_status_values+=("Disconnected")
            fi
        elif [[ "$STATUS" = "Connected" ]]; then
            group_status_values[$index]="Connected"
        fi
    done <<< "$1"  # sort 제거

    # 디버깅: group_status 전체 출력
    # echo "Debug: Group Status"
    # for i in "${!group_status_keys[@]}"; do
    #     echo "${group_status_keys[$i]}: ${group_status_values[$i]}"
    # done
    # echo "---"
    # 정렬된 라인을 처리
    for line in "${sorted_lines[@]}"; do
        STATUS=$(echo "$line" | awk '{print $2}' | tr -d '()')
        NAME=$(echo "$line" | sed -E 's/.*"(.*)".*/\1/')
        IFS='-' read -ra LEVELS <<< "$NAME"

        # 그룹 레벨 표시 (중복 제거 및 상태 아이콘 추가)
        current_group="${LEVELS[0]}"
        if [ "$current_group" != "$prev_group" ]; then
            # 그룹 상태 확인
            group_status="Disconnected"
            for i in "${!group_status_keys[@]}"; do
                if [[ "${group_status_keys[$i]}" = "$current_group" ]]; then
                    group_status="${group_status_values[$i]}"
                    break
                fi
            done

            if [ "$group_status" = "Connected" ]; then
                echo ":eye.fill: $current_group  | color=blue sfcolor=blue"
            else
                echo ":eye.slash: $current_group  | xsfcolor=orange"
            fi
            prev_group="$current_group"
        fi

        # VPN 상태 및 동작 표시
        local prefix=$(printf '%0.s--' $(seq 1 $((${#LEVELS[@]} - 1))))
        if [ "$STATUS" = "Connected" ]; then
            if check_internet; then
                echo "${prefix}:eye.fill: $NAME: $ELAPSED_TIME | color=blue sfcolor=blue"
            else
                echo "${prefix}:eye.slash.fill: $NAME: $STATUS (No Internet) | color=orange sfcolor=orange"
            fi
            echo "${prefix}--Disconnect | bash=$HOME/.SwiftBar/helpers/vpn_action.sh param1=stop param2=\"$NAME\" param3=\"$CURRENT_PLUGIN_NAME\" terminal=false"
        else
            echo "${prefix}:eye.slash: $NAME: $STATUS | xsfcolor=orange"
            echo "${prefix}--Connect | bash=$HOME/.SwiftBar/helpers/vpn_action.sh param1=start param2=\"$NAME\" param3=\"$CURRENT_PLUGIN_NAME\" terminal=false"
        fi
    done
}

CURRENT_PLUGIN_NAME=$(basename "$SWIFTBAR_PLUGIN_PATH")

# Get all VPN connections
VPN_LIST=$(/usr/sbin/scutil --nc list | grep -E '^\*.*IPSec' | sort -k 4)

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
        echo ":eye.fill:$VPN_NAME($ELAPSED_TIME) | color=blue sfcolor=blue xsfsize=16 xfont=D2coding"
        echo "---"
        echo $VPN_NAME
        # echo $(date +"%Y-%m-%d %H:%M:%S")
        echo "Connected for: $ELAPSED_TIME"
    else
        echo ":eye.fill:$VPN_NAME (!) | color=orange sfcolor=orange sfsize=16 xfont=D2coding"
        echo "---"
        echo $VPN_NAME
        # echo $(date +"%Y-%m-%d %H:%M:%S")
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
print_vpn_hierarchy "$VPN_LIST"


echo "---"
echo "Refresh | refresh=true"
# echo "List Network Services | bash=$HOME/.SwiftBar/vpn_list.sh terminal=false"