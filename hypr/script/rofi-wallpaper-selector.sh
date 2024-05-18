#!/usr/bin/env sh

[ -z "${1}" ] || opt="${1}"
wallpapers_dir="$HOME/Pictures/Wallpapers"
PICS=($(ls "${wallpapers_dir}" | grep -E ".jpg$|.jpeg$|.png$|.gif$"))
rofiConf="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/wallpaper-selector.rasi"

menu() {
  for i in "${!PICS[@]}"; do
    if [[ -z $(echo "${PICS[$i]}" | grep .gif$) ]]; then
      printf "$(echo "${PICS[$i]}")\x00icon\x1f${wallpapers_dir}/${PICS[$i]}\n"
    else
      printf "${PICS[$i]}\n"
    fi
  done
}

menu

case "${opt}" in
    0)  w0=$(ls "${wallpapers_dir}" | shuf -n 1)
        swww img "${wallpapers_dir}/${w0}" \
            --transition-type=simple \
            --transition-duration=2 \
            --transition-fps=30
        exit 0 ;;
    1)  w1=$(ls "${wallpapers_dir}" | shuf -n 1)
        swww img "${wallpapers_dir}/${w1}" \
            --transition-type=any \
            --transition-duration=2 \
            --transition-fps=30
        exit 0 ;;
    2)  w2=$(menu | rofi -show -dmenu -width 1 -config  "${rofiConf}")
        if [ ! -z "${w2}" ] ; then
            swww img "$HOME/Pictures/Wallpapers/${w2}" \
                --transition-type=random \
                --transition-duration=3 \
                --transition-fps=30
        fi
        exit 0 ;;
esac
