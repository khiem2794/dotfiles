#!/bin/sh

current=$(grep -o -E 'catppuccin_\w+' ~/.config/hypr/hyprland.conf | cut -d '_' -f2)
new="mocha"

if [ $current = "mocha" ]; then
    new="latte"
    vscode_theme="Catppuccin Latte"
    swww img ~/Pictures/Wallpapers/_latte.png --transition-type center --transition-fps 60
    cp ~/.mozilla/firefox/*.default-release/chrome/userContent-latte.css ~/.mozilla/firefox/*.default-release/chrome/userContent.css
    cp ~/.config/dunst/dunstrc.latte ~/.config/dunst/dunstrc
    killall calibre; sed -i "s/\"dark\"/\"light\"/g" ~/.config/calibre/gui.json
else
    new="mocha"
    vscode_theme="Catppuccin Mocha"
    swww img ~/Pictures/Wallpapers/_mocha.png --transition-type center --transition-fps 60
    cp ~/.mozilla/firefox/*.default-release/chrome/userContent-mocha.css ~/.mozilla/firefox/*.default-release/chrome/userContent.css
    cp ~/.config/dunst/dunstrc.mocha ~/.config/dunst/dunstrc
    killall calibre; sed -i "s/\"light\"/\"dark\"/g" ~/.config/calibre/gui.json
fi


sed -i "s/catppuccin_$current/catppuccin_$new/g" ~/.config/hypr/hyprland.conf
sed -i "s/catppuccin_$current/catppuccin_$new/g" ~/.config/kitty/kitty.conf
sed -i "s/catppuccin_$current/catppuccin_$new/g" ~/.config/rofi/app-launcher.rasi
sed -i "s/catppuccin_$current/catppuccin_$new/g" ~/.config/rofi/clipboard.rasi
sed -i "s/catppuccin_$current/catppuccin_$new/g" ~/.config/rofi/wallpaper-selector.rasi
sed -i "s/catppuccin_$current/catppuccin_$new/g" ~/.config/waybar/style.css
sed -i "s/catppuccin_$current/catppuccin_$new/g" ~/.config/wlogout/style.css
sed -i "s/catppuccin_$current/catppuccin_$new/g" ~/.config/zathura/zathurarc
sed -i "s/\"catppuccin_$current\"/\"catppuccin_$new\"/g" ~/.config/starship/starship.toml

sed -i "s/catppuccin-$current/catppuccin-$new/g" ~/.config/nvim/lua/plugins/colorscheme.lua
sed -i -e "s/\"workbench.colorTheme\": \".*\"/\"workbench.colorTheme\": \"$vscode_theme\"/g" ~/.config/Code/User/settings.json


#restart
killall -SIGUSR2 waybar
killall dunst; dunst &
