#!/usr/bin/env sh

[ -z "${1}" ] || opt="${1}"
wallpapers_dir="$HOME/Pictures/Wallpapers"
thumbDir="$HOME/.cache/wallpapers/thumbs"
confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
rofiConf="${confDir}/rofi/selector.rasi"
hypr_border="$(hyprctl -j getoption decoration:rounding | jq '.int')"
hypr_width="$(hyprctl -j getoption general:border_size | jq '.int')"
[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
elem_border=$(( hypr_border * 3 ))
col_count=5
line_count=2
r_theme="window{width:100%;} listview{columns:${col_count};lines:${line_count};spacing:5em;} element{border-radius:${elem_border}px;orientation:vertical;} element-icon{size:10em;border-radius:0em;} element-text{padding:1em;}"
r_theme_2="listview{spacing:5em;} element{border-radius:${elem_border}px;orientation:vertical;}"

case "${opt}" in
    1)  w1=$(ls "${wallpapers_dir}" | shuf -n 1)
        swww img "${wallpapers_dir}/${w1}" \
            # --transition-type=random \
            --transition-duration=1
        exit 0 ;;
    2)  w2=$(ls "${wallpapers_dir}" | rofi -dmenu -p "Select Wallpaper" )
        swww img "${wallpapers_dir}/${w2}" \
            # --transition-type=random \
            --transition-duration=1
        exit 0 ;;
esac


rofiSel=$(ls $HOME/Pictures/Wallpapers | rofi -dmenu -theme-str "${r_theme}" -config "${rofiConf}")
if [ ! -z "${rofiSel}" ] ; then
    echo "$HOME/Pictures/Wallpapers/${rofiSel}"
    swww img "$HOME/Pictures/Wallpapers/${rofiSel}"
fi

