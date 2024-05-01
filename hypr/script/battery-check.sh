#!/usr/bin/env bash

is_laptop() {
    if grep -q "Battery" /sys/class/power_supply/BAT*/type; then
        return 0
    else
        echo "No battery detected."
        exit 0
    fi
}
is_laptop

while true; do
    battery_status=$(cat /sys/class/power_supply/BAT0/status)
    battery_capacity=$(cat /sys/class/power_supply/BAT0/capacity)

    if [ $battery_capacity -le 10 ] && [ $battery_status == "Discharging" ]; then
        notify-send -a "Power" "Battery Low" -u critical "Battery is at $battery_capacity%."
        brightnessctl set 10%
    fi
    sleep 60
done
