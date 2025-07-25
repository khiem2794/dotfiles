#!/usr/bin/env bash

roconf="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/powermenu.rasi"

uptime="`uptime -p | sed -e 's/up //g'`"
host=`hostname`

shutdown=' shutdown'
reboot=' restart'
lock=' lock'
suspend='󰤄 suspend'
logout='󰍃 logout'
exit='󰩈 exit'

rofi_cmd() {
	rofi -dmenu \
		-p "Uptime: $uptime" \
		-mesg "Uptime: $uptime" \
		-theme ${roconf}
}

run_rofi() {
	echo -e "$lock\n$exit\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
		systemctl poweroff
        ;;
    $reboot)
		systemctl reboot
        ;;
    $lock)
        hyprlock
        ;;
    $suspend)
		systemctl suspend
        ;;
    $logout)
		hyprctl dispatch exit 0
        ;;
    $exit)
        hyprctl dispatch exit 1
        ;;
esac