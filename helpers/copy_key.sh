#!/bin/bash
echo "$1" | pbcopy
osascript -e "display notification \"Key copied: $1\" with title \"🔑 Time Key\"
"
