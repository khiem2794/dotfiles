#!/usr/bin/env sh

if pgrep -x "wlogout" > /dev/null
then
    pkill -x "wlogout"
    exit 0
fi
A_1080=250
B_1080=250
confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
wLayout="${confDir}/wlogout/layout"
wlTmplt="${confDir}/wlogout/style.css"
resolution=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .height / .scale' | awk -F'.' '{print $1}')
hypr_scale=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .scale')

#// eval config files
wStyle="$(envsubst < $wlTmplt)"

wlogout --layout "${wLayout}" --css <(echo "${wStyle}") --protocol layer-shell -T $(awk "BEGIN {printf \"%.0f\", $A_1080 * 1080 * $hypr_scale / $resolution}") -B $(awk "BEGIN {printf \"%.0f\", $B_1080 * 1080 * $hypr_scale / $resolution}") &
