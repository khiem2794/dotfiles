#!/usr/bin/env sh

roconf="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/app-launcher.rasi"

case "${1}" in
    d|--drun) r_mode="drun" ;; 
    w|--window) r_mode="window" ;;
    f|--filebrowser) r_mode="filebrowser" ;;
    h|--help) echo -e "$(basename "${0}") [action]"
        echo "d :  drun mode"
        echo "w :  window mode"
        echo "f :  filebrowser mode,"
        exit 0 ;;
    *) r_mode="drun" ;;
esac

rofi -show "${r_mode}" -config "${roconf}"
