## Custom archlinux & hyprland rice install steps (Thinkpad T14s)

### 1. Archinstall (Extra packages: neovim sudo git)
```
iwctl
device list
station [name] scan
station [name] connect Helicopter
exit
```

### 2. After rebooting, connect wifi + install some package
```
nmtui
sudo pacman -S wget unzip polkit-gnome pacman-contrib lazygit
sudo pacman -S udiskie
sudo pacman -S brightnessctl 
sudo pacman -S pavucontrol pamixer
sudo pacman -S network-manager-applet bluez bluez-utils blueman
sudo pacman -S imv mpv #img viewer + media player
```

### 3. Installing yay
```
mkdir Repos && cd Repos
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### 4. Clonning dotfiles
```
cd ~/Repos && git clone https://github.com/khiem2794/dotfiles
```

### 5. Installing hyprland and start desktop mode
```
sudo pacman -S hyprland hyprlock kitty xdg-desktop-portal-hyprland
rm -rf ~/.config/hyprland
cp -r ~/Repos/dotfiles/hypr ~/.config/
cp -r ~/Repos/dotfiles/kitty ~/.config/
Hyprland #Super + R after to start kitty
```

### Installing + Config FastFetch
```
sudo pacman -S fastfetch imagemagick
cp ~/Repos/dotfiles/fastfetch ~/.config/
```

### Installing themes, icons, fonts
```
yay -S tela-circle-icon-theme-dracula dracula-gtk-theme bibata-cursor-theme-bin ttf-mapple
sudo pacman -S nwg-look ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd noto-fonts-emoji
nwg-look #change to widget to dracula and cursor to bibata-modern-ice
```

### Installing File browser (Super + E)
```
sudo pacman -S thunar gvfs
```

### Installing VSCode (Super + C)
```
yay -S visual-studio-code-bin
cp ~/Repos/dotfiles/Code ~/.config/
#install tokyo night theme
```

### Installing Firefox (Super + F) 
- Enable toolkit.legacyUserProfileCustomizations.stylesheets
- Copy https://gist.github.com/khiem2794/4c8cd1e43c5bdf6c630cc314c55201e9
```
sudo pacman -S firefox
```

### Installing + Config Waybar
```
sudo pacman -S waybar
cp ~/Repos/dotfiles/Code ~/.config/
```

### Installing + Config Dunst
```
sudo pacman -S dunst libnotify
cp ~/Repos/dotfiles/dunst ~/.config/
```

### Installing screenshot tools (Super + P)
```
sudo pacman -S slurp swappy cliphist && yay -S grimblast-git
```

### Installing + Config Rofi (Super + A | Super + Shift + E | Super + Tab)
```
yay -S rofi-lbonn-wayland-git
cp ~/Repos/dotfiles/rofi ~/.config/
```

### Installing + Config Wlogout (Super + Backspace | Super + Shift + Backspace)
```
yay -S wlogout
cp ~/Repos/dotfiles/wlogout ~/.config/
```

### Installing Swww for Wallpaper
```
yay -S swww
mkdir ~/Pictures
mkdir ~/Pictures/Wallpapers #Download and put wallpapers here
```

### Installing Warp VPN
```
yay -S cloudflare-warp-bin 
sudo systemctl enable warp-svc
warp-cli connect
```

### Installing + Config Starship prompt
```
sudo pacman -S starship
echo "export STARSHIP_CONFIG=~/.config/starship/starship.toml" >> ~/.bashrc
echo "eval \"\$(starship init bash)\"" >> ~/.bashrc
rm ~/.config/starship.toml
cp ~/Repos/dotfiles/starship ~/.config/
```

### Installing + Config Tmux
```
sudo pacman -S tmux
cp ~/Repos/dotfiles/tmux ~/.config/
```

### Updating Grub settings
```
sudo nvim /etc/defaut/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Installing + Config SDDM
```
sudo pacman -S sddm
yay -S sddm-theme-corners-git #settings in /usr/share/sddm/themes/corners/
sudo cp /usr/lib/sddm/sddm.conf.d/default.conf /etc/sddm.conf
sudo nvim /etc/sddm.conf #change theme to corners
sudo systemctl enable sddm 
```

### Installing TimeShift and create backup
```
sudo pacman -S  timeshift
sudo -E timeshift-launcher
sudo nvim /usr/share/applications/timeshift-gtk.desktop #fixing not start in rofi
```

# Replace some dracula theme color
```
cd /usr/share/themes/Dracula
sed -i 's/282a36/1a1b26/g' *
sed -i 's/232530/1a1b26/g' *
sed -i 's/2a2c39/1a1b26/g' *
```

### Installing nvm
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install --lts
```

# fixing cursor state, system-wide changed https://wiki.archlinux.org/title/Cursor_themes#Configuration 
