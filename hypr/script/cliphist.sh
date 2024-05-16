#!/usr/bin/env sh

#// evaluate spawn position
readarray -t curPos < <(hyprctl cursorpos -j | jq -r '.x,.y')
readarray -t monRes < <(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width,.height,.scale,.x,.y')
readarray -t offRes < <(hyprctl -j monitors | jq -r '.[] | select(.focused==true).reserved | map(tostring) | join("\n")')
monRes[2]="$(echo "${monRes[2]}" | sed "s/\.//")"
monRes[0]="$(( ${monRes[0]} * 100 / ${monRes[2]} ))"
monRes[1]="$(( ${monRes[1]} * 100 / ${monRes[2]} ))"
curPos[0]="$(( ${curPos[0]} - ${monRes[3]} ))"
curPos[1]="$(( ${curPos[1]} - ${monRes[4]} ))"

if [ "${curPos[0]}" -ge "$((${monRes[0]} / 2))" ] ; then
    x_pos="east"
    x_off="-$(( ${monRes[0]} - ${curPos[0]} - ${offRes[2]} ))"
else
    x_pos="west"
    x_off="$(( ${curPos[0]} - ${offRes[0]} ))"
fi

if [ "${curPos[1]}" -ge "$((${monRes[1]} / 2))" ] ; then
    y_pos="south"
    y_off="-$(( ${monRes[1]} - ${curPos[1]} - ${offRes[3]} ))"
else
    y_pos="north"
    y_off="$(( ${curPos[1]} - ${offRes[1]} ))"
fi

r_override="window{location:${x_pos} ${y_pos};anchor:${x_pos} ${y_pos};x-offset:${x_off}px;y-offset:${y_off}px;}"
roconf="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/clipboard.rasi"

#// clipboard action
case "${1}" in
    c|-c|--copy)
        cliphist list | rofi -dmenu -theme-str "entry { placeholder: \"Copy...\";}" -theme-str "${r_override}" -config "${roconf}" | cliphist decode | wl-copy
        ;;
    d|-d|--delete)
        cliphist list | rofi -dmenu -theme-str "entry { placeholder: \"Delete...\";}" -theme-str "${r_override}" -config "${roconf}" | cliphist delete
        ;;
    w|-w|--wipe)
        if [ $(echo -e "Yes\nNo" | rofi -dmenu -theme-str "entry { placeholder: \"Clear Clipboard History?\";}" -theme-str "${r_override}" -config "${roconf}") == "Yes" ] ; then
            cliphist wipe
        fi
        ;;
    *)
        echo -e "cliphist.sh [action]"
        echo "c -c --copy    :  cliphist list and copy selected"
        echo "d -d --delete  :  cliphist list and delete selected"
        echo "w -w --wipe    :  cliphist wipe database"
        exit 1
        ;;
esac
