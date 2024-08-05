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

# List of coin drivers to load
COIN_DRIVERS=("gopax_gxa.sh" "upbit_btc.sh")

main_symbol=""
main_price=""
dropdown_output=""
previous_exchange=""

for driver in "${COIN_DRIVERS[@]}"; do
    source "$SCRIPT_DIR/helpers/coins/$driver"

    price=$(get_price)
    full_symbol=$(get_symbol)
    symbol=$(echo "${full_symbol:0:1}" | tr '[:upper:]' '[:lower:]')
    exchange=$(get_exchange)

    if [ -z "$main_symbol" ]; then
        main_symbol=$symbol
        main_price=$price
    fi

    if [[ "$price" == "Error:"*  ]]; then
        current_output="$full_symbol: Error ($exchange)"
    else
        current_output="$full_symbol: $(format_number $price) ($exchange)"
    fi

    if [ "$exchange" != "$previous_exchange" ] && [ -n "$previous_exchange" ]; then
        dropdown_output+="---\n"
    fi

    dropdown_output+="$current_output\n"
    dropdown_output+="$(get_link)\n"

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
echo "Refresh | refresh=true"