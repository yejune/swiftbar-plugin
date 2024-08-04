#!/bin/bash
# <bitbar.title>Gopax GXA Price</bitbar.title>
# <bitbar.version>v1.5</bitbar.version>
# <bitbar.author>Yejune</bitbar.author>
# <bitbar.author.github>yejune</bitbar.author.github>
# <bitbar.desc>Shows Gopax GXA price with 2 decimal places</bitbar.desc>
# <bitbar.dependencies>bash,curl</bitbar.dependencies>

# Gopax API endpoint for GXA/KRW ticker
URL="https://api.gopax.co.kr/trading-pairs/GXA-KRW/ticker"

# Timeout in seconds
TIMEOUT=5

# Function to format number with commas and 2 decimal places
format_number() {
    printf "%'.*f" 2 "$1"
}

# Check if curl is available
if ! command -v curl &> /dev/null
then
    echo "GXA: Error"
    echo "---"
    echo "Error: curl is not installed"
    exit 0
fi

# Fetch data from Gopax with timeout
response=$(curl -s -m $TIMEOUT "$URL")

if [ $? -ne 0 ]; then
    echo "GXA: Lost Connection | color=gray"
    echo "---"
    echo "Error: Failed to fetch data from Gopax within $TIMEOUT seconds"
    exit 0
fi

# Parse JSON and extract price using grep and cut
price=$(echo "$response" | grep -o '"price":[0-9.]*' | cut -d':' -f2)

if [ -z "$price" ]; then
    echo "GXA: Error"
    echo "---"
    echo "Error: Failed to parse price from response"
    echo "Raw response: $response"
    exit 0
fi

# Format price with 2 decimal places
formatted_price=$(format_number $price)

# Get current time
current_time=$(date +"%H:%M:%S")

# Output for SwiftBar
echo "GXA: ₩$formatted_price | color=gray xfont=Menlo"
echo "---"
echo "Price: ₩$formatted_price"
echo "Updated: $current_time"
echo "---"
echo "Open Gopax | href=https://www.gopax.co.kr/exchange/GXA-KRW"