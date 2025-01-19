!/bin/sh

current=$(grep -o -E 'themes/\w+' ~/.config/hypr/themes/theme.conf | cut -d '_' -f2)
new="light"

if [ $current = "light" ]; then
    new="dark"
    vscode_theme="Gruvbox Dark Medium"
    hyprctl hyprpaper wallpaper ",~/.config/hypr/assets/_dark.png"
else
    new="light"
    vscode_theme="Gruvbox Light Hard"
    hyprctl hyprpaper wallpaper ",~/.config/hypr/assets/_light.png"
fi


sed -i "s/_$current/_$new/g" ~/.config/hypr/themes/theme.conf
sed -i "s/_$current/_$new/g" ~/.config/kitty/kitty.conf
sed -i "s/_$current/_$new/g" ~/.config/rofi/app-launcher.rasi
sed -i "s/_$current/_$new/g" ~/.config/rofi/clipboard.rasi
sed -i "s/_$current/_$new/g" ~/.config/rofi/powermenu.rasi
sed -i "s/_$current/_$new/g" ~/.config/waybar/style.css
sed -i "s/_$current/_$new/g" ~/.config/zathura/zathurarc

sed -i "s/\"$current\"/\"$new\"/g" ~/.config/nvim/lua/plugins/colorscheme.lua
sed -i -e "s/\"workbench.colorTheme\": \".*\"/\"workbench.colorTheme\": \"$vscode_theme\"/g" ~/.config/Code/User/settings.json

#restart
killall -SIGUSR2 waybar
killall -SIGUSR1 kitty
