#!/bin/bash

URL="https://api.upbit.com/v1/ticker?markets=KRW-SOL"
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

    local price=$(echo "$response" | grep -o '"trade_price":[0-9.]*' | cut -d':' -f2)

    if [ -z "$price" ]; then
        echo "Error: Parse failed"
        return
    fi

    echo "$price"
}

get_symbol() {
    echo "SOL"
}

get_exchange() {
    echo "Upbit"
}

get_link() {
    echo "Open Upbit SOL | href=https://upbit.com/exchange?code=CRIX.UPBIT.KRW-SOL"
}