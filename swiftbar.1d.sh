#!/bin/bash
# <bitbar.title>bitbar 설정</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Your Name</bitbar.author>
# <bitbar.author.github>yourgithubusername</bitbar.author.github>
# <bitbar.desc>bitbar 설정을 열 수 있는 플러그인</bitbar.desc>
# <bitbar.dependencies></bitbar.dependencies>
# <bitbar.refreshTime>86400</bitbar.refreshTime>

echo ":cat:"
echo "---"
echo "SwiftBar 설정 열기 | shell=open param1='swiftbar://openPreferences' terminal=false"
echo "플러그인 폴더 열기 | shell=open param1='$HOME/.swiftbar' terminal=false"
echo "모든 플러그인 새로고침 | shell=open param1='swiftbar://refreshAllPlugins' terminal=false"
echo "SwiftBar 재시작 | bash=/bin/bash param1=-c param2='killall SwiftBar && sleep 2 && open -a SwiftBar' terminal=false"