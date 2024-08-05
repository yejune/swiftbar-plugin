#!/bin/bash

URL="https://api.gopax.co.kr/trading-pairs/GXA-KRW/ticker"
TIMEOUT=2

get_price() {
    if ! command -v curl &> /dev/null
    then
        echo "Error: No curl"
        return
    fi

    local response=$(curl -s -m $TIMEOUT "$URL")

    if [ $? -ne 0 ]; then
        echo "Error: Fetch failed"
        return
    fi

    if [ -z "$response" ]; then
        echo "Error: No data"
        return
    fi

    local price=$(echo "$response" | grep -o '"price":[0-9.]*' | cut -d':' -f2)

    if [ -z "$price" ]; then
        echo "Error: Parse failed"
        return
    fi

    echo "$price"
}

get_symbol() {
    echo "GXA"
}

get_exchange() {
    echo "Gopax"
}

get_link() {
    echo "Open Gopax GXA | href=https://www.gopax.co.kr/exchange/GXA-KRW"
}