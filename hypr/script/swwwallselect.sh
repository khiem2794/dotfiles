#!/usr/bin/env sh

[ -z "${1}" ] || opt="${1}"
wallpapers_dir="$HOME/Pictures/Wallpapers"
PICS=($(ls "${wallpapers_dir}" | grep -E ".jpg$|.jpeg$|.png$|.gif$"))
rofiConf="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/wallpaper-selector.rasi"
r_theme="window{width:80%;} element{border-radius:1em;orientation:vertical;}"


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
    1)  w1=$(ls "${wallpapers_dir}" | shuf -n 1)
        swww img "${wallpapers_dir}/${w1}" \
            --transition-type=random \
            --transition-duration=1 \
            --transition-fps=30
        exit 0 ;;
    2)  w2=$(menu | rofi -show -dmenu -theme-str "${r_theme}" -config  "${rofiConf}")
        if [ ! -z "${w2}" ] ; then
            echo "Selected: ${w2}"
            swww img "$HOME/Pictures/Wallpapers/${w2}" \
                --transition-type=random \
                --transition-duration=1 \
                --transition-fps=30
        fi
        exit 0 ;;
esac
