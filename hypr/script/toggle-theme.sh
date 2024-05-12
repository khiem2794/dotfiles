#!/bin/sh

current=$(grep -o -E 'theme_\w+' ~/.config/hypr/hyprland.conf | cut -d '_' -f2)
new="light"

if [ $current = "night" ]; then
    new="light"

    # change the theme in vscode
    sed -i -e 's/"workbench.colorTheme": ".*"/"workbench.colorTheme": "Tokyo Night Light"/g' "$HOME/.config/Code/User/settings.json"

    # change firefox uesrContent
    cp ~/.mozilla/firefox/*.default-release/chrome/userContent-light.css ~/.mozilla/firefox/*.default-release/chrome/userContent.css

    #change neovim color scheme
    sed -i 's/tokyonight-night/tokyonight-day/g' "$HOME/.config/nvim/lua/plugins/colorscheme.lua"
else
    new="night"
    sed -i -e 's/"workbench.colorTheme": ".*"/"workbench.colorTheme": "Tokyo Night"/g' "$HOME/.config/Code/User/settings.json"
    cp ~/.mozilla/firefox/*.default-release/chrome/userContent-night.css ~/.mozilla/firefox/*.default-release/chrome/userContent.css
    sed -i 's/tokyonight-day/tokyonight-night/g' "$HOME/.config/nvim/lua/plugins/colorscheme.lua"
fi


sed -i "s/theme_$current/theme_$new/g" ~/.config/hypr/hyprland.conf
sed -i "s/theme_$current/theme_$new/g" ~/.config/kitty/kitty.conf
sed -i "s/theme_$current/theme_$new/g" ~/.config/rofi/app-launcher.rasi
sed -i "s/theme_$current/theme_$new/g" ~/.config/rofi/clipboard.rasi
sed -i "s/theme_$current/theme_$new/g" ~/.config/rofi/notification.rasi
sed -i "s/theme_$current/theme_$new/g" ~/.config/rofi/wallpaper-selector.rasi
sed -i "s/theme_$current/theme_$new/g" ~/.config/waybar/style.css
sed -i "s/theme_$current/theme_$new/g" ~/.config/wlogout/style_1.css
sed -i "s/theme_$current/theme_$new/g" ~/.config/wlogout/style_2.css

#restart the waybar
killall -SIGUSR2 waybar