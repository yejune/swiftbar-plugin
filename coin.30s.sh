#!/bin/bash
# <bitbar.title>Multi Coin Price Tracker</bitbar.title>
# <bitbar.version>v3.6</bitbar.version>
# <bitbar.author>Yejune</bitbar.author>
# <bitbar.author.github>yejune</bitbar.author.github>
# <bitbar.desc>Shows prices of multiple coins from different exchanges</bitbar.desc>
# <bitbar.dependencies>bash,curl,jq</bitbar.dependencies>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>

SCRIPT_DIR="$(dirname "$0")"

export LC_NUMERIC="en_US.UTF-8"
format_number() {
    if [[ "$1" == "Error:"* ]]; then
        echo "$1"
    else
        if [ "$2" = "0" ]; then
            printf "%'.*f" 2 "$1"
        else
            printf "₩%'.*f" 2 "$1"
        fi
    fi
}

CONFIG_FILE="$SCRIPT_DIR/.config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "❌ Config Error"
    echo "---"
    echo "Config file not found: $CONFIG_FILE"
    echo "Please create config file with SECRET variable"
    echo "---"
    echo "Create Config | bash='touch $CONFIG_FILE && echo \"SECRET=\\\"your-secret-here\\\"\" > $CONFIG_FILE' terminal=false"
    exit 1
fi

# 키 생성
gen_key() {
    echo -n "${SECRET}$(date +%Y%m%d%H)" | sha256sum | cut -c1-16
}

# 키 검증 (10분 유효)
check_key() {
    local key="$1"
    local current=$(gen_key)
    local previous=$(echo -n "${SECRET}$(date -d '1 hour ago' +%Y%m%d%H)" | sha256sum | cut -c1-16)

    [[ "$key" == "$current" ]] && return 0
    [[ $(date +%M) -lt 10 && "$key" == "$previous" ]] && return 0
    return 1
}

# List of coin drivers to load (쉼표 제거!)
COIN_DRIVERS=("gopax_gxa.sh" "upbit_btc.sh" "upbit_eth.sh" "upbit_sol.sh")

main_symbol=""
main_price=""
dropdown_output=""
previous_exchange=""

for driver in "${COIN_DRIVERS[@]}"; do
    # 파일 존재 여부 확인
    if [ ! -f "$SCRIPT_DIR/helpers/coins/$driver" ]; then
        echo "Warning: $driver not found" >&2
        continue
    fi

    # 소스 로드 전에 함수 초기화
    unset -f get_price get_symbol get_exchange get_link

    source "$SCRIPT_DIR/helpers/coins/$driver"

    # 함수 존재 여부 확인
    if ! declare -f get_price > /dev/null; then
        echo "Warning: get_price function not found in $driver" >&2
        continue
    fi

    price=$(get_price)
    full_symbol=$(get_symbol)
    symbol=$(echo "${full_symbol:0:1}" | tr '[:upper:]' '[:lower:]')
    exchange=$(get_exchange)

    if [ -z "$main_symbol" ]; then
        main_symbol=$symbol
        main_price=$price
    fi

    if [[ "$price" == "Error:"* ]]; then
        current_output="$full_symbol: Error ($exchange)"
    else
        current_output="$full_symbol: $(format_number $price) ($exchange)"
    fi

    if [ "$exchange" != "$previous_exchange" ] && [ -n "$previous_exchange" ]; then
        dropdown_output+="---\n"
    fi

    dropdown_output+="$current_output\n"

    # get_link 함수 존재 여부 확인
    if declare -f get_link > /dev/null; then
        dropdown_output+="$(get_link)\n"
    fi

    previous_exchange=$exchange
done

if [[ "$main_price" == "Error:"* ]]; then
    main_output=":$main_symbol.circle.fill:$main_price| xcolor=gray xfont=Menlo"
else
    main_output=":$main_symbol.circle:$(format_number $main_price 0)| color=gray xfont=Menlo"
fi

echo "$main_output"
echo "---"
echo -e "$dropdown_output"
echo "---"
echo "Last Updated: $(date +"%H:%M:%S")"

echo "---"
# 현재 키 표시 및 클립보드 복사 기능

current_key=$(gen_key)
echo "🔑 Key: $current_key | bash='$SCRIPT_DIR/helpers/copy_key.sh' param1='$current_key' terminal=false"

echo "---"
echo "Refresh | refresh=true"