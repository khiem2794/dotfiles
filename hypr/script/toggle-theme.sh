#!/bin/sh

current=$(grep -o -E 'themes/\w+' ~/.config/hypr/themes/theme.conf | cut -d '_' -f2)
new="light"
current_zellij_theme="gruvbox-dark"
new_zellij_theme="gruvbox-dark"

if [ $current = "light" ]; then
    new="dark"
    current_zellij_theme="gruvbox-light"
    new_zellij_theme="gruvbox-dark"
    vscode_theme="Gruvbox Dark Soft"
    hyprctl hyprpaper wallpaper ",~/.config/hypr/assets/_black.png"
    gsettings set org.gnome.desktop.interface gtk-theme 'Gruvbox-Dark'
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
    rm -rf ~/.local/share/icons/default
    ln -s /usr/share/icons/Bibata-Modern-Ice/ ~/.local/share/icons/default
else
    new="light"
    current_zellij_theme="gruvbox-dark"
    new_zellij_theme="gruvbox-light"
    vscode_theme="Gruvbox Light Hard"
    hyprctl hyprpaper wallpaper ",~/.config/hypr/assets/_white.png"
    gsettings set org.gnome.desktop.interface gtk-theme 'Gruvbox-Light'
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'
    rm -rf ~/.local/share/icons/default
    ln -s /usr/share/icons/Bibata-Modern-Clasic/ ~/.local/share/icons/default
fi


sed -i "s/_$current/_$new/g" ~/.config/hypr/themes/theme.conf
sed -i "s/_$current/_$new/g" ~/.config/kitty/kitty.conf
sed -i "s/_$current/_$new/g" ~/.config/rofi/app-launcher.rasi
sed -i "s/_$current/_$new/g" ~/.config/rofi/clipboard.rasi
sed -i "s/_$current/_$new/g" ~/.config/rofi/powermenu.rasi
sed -i "s/_$current/_$new/g" ~/.config/waybar/style.css
sed -i "s/_$current/_$new/g" ~/.config/zathura/zathurarc
sed -i "s/"$current_zellij_theme/"$new_zellij_theme/g" ~/.config/zellij/config.kdl

sed -i "s/\"$current\"/\"$new\"/g" ~/.config/nvim/lua/plugins/colorscheme.lua
sed -i -e "s/\"workbench.colorTheme\": \".*\"/\"workbench.colorTheme\": \"$vscode_theme\"/g" ~/.config/Code/User/settings.json

hyprshade on ~/.config/hypr/shader/gridlines.frag

#restart
killall -SIGUSR2 waybar
killall -SIGUSR1 kitty
