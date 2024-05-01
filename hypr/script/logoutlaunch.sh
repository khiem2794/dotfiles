#!/usr/bin/env sh


#// Check if wlogout is already running
if pgrep -x "wlogout" > /dev/null
then
    pkill -x "wlogout"
    exit 0
fi


wlogoutStyle=2
[ -z "${1}" ] || wlogoutStyle="${1}"
confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
wLayout="${confDir}/wlogout/layout_${wlogoutStyle}"
wlTmplt="${confDir}/wlogout/style_${wlogoutStyle}.css"
hypr_border="$(hyprctl -j getoption decoration:rounding | jq '.int')"
hypr_width="$(hyprctl -j getoption general:border_size | jq '.int')"

if [ ! -f "${wLayout}" ] || [ ! -f "${wlTmplt}" ] ; then
    echo "ERROR: Config ${wlogoutStyle} not found..."
    wlogoutStyle=1
    wLayout="${confDir}/wlogout/layout_${wlogoutStyle}"
    wlTmplt="${confDir}/wlogout/style_${wlogoutStyle}.css"
fi

#// detect monitor res
x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
hypr_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')


#// scale config layout and style
case "${wlogoutStyle}" in
    1)  wlColms=6
        export mgn=$(( y_mon * 35 / hypr_scale ))
        export hvr=$(( y_mon * 30 / hypr_scale )) ;;
    2)  wlColms=2
        export x_mgn=$(( x_mon * 37 / hypr_scale ))
        export y_mgn=$(( y_mon * 28 / hypr_scale ))
        export x_hvr=$(( x_mon * 34 / hypr_scale ))
        export y_hvr=$(( y_mon * 24 / hypr_scale )) ;;
esac


#// scale font size
export fntSize=$(( y_mon * 2 / 80 ))


#// eval hypr border radius
export active_rad=$(( hypr_border * 5 ))
export button_rad=$(( hypr_border * 8 ))


#// eval config files
wlStyle="$(envsubst < $wlTmplt)"


wlogout -b "${wlColms}" -c 0 -r 0 -m 0 --layout "${wLayout}" --css <(echo "${wlStyle}") --protocol layer-shell
