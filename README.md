# Archlinux & Hyprland setup (Thinkpad T14s)

## 1. Setting up Archlinux & Hyprland

<details>
<summary><b>Archinstall</b></summary>

- Extra packages: neovim sudo git

</details>


<details>
  <summary><b>After rebooting, connect wifi + install some packages</b></summary>

  ```bash
    nmtui
    sudo pacman -S wget unzip polkit-gnome pacman-contrib lazygit
    sudo pacman -S udiskie
    sudo pacman -S brightnessctl 
    sudo pacman -S pavucontrol pamixer
    sudo pacman -S network-manager-applet bluez bluez-utils blueman
  ```

</details>

<details>
  <summary><b>Installing yay & Clonning dotfiles</b></summary>

  ```bash
    mkdir Repos && cd Repos
    git clone https://github.com/khiem2794/dotfiles
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
  ```

</details>

<details>
  <summary><b>Installing required themes, icons, fonts</b></summary>

  ```bash
    yay -S tela-circle-icon-theme-dracula catppuccin-gtk-theme-mocha catppuccin-gtk-theme-latte bibata-cursor-theme-bin ttf-mapple
    sudo pacman -S ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd noto-fonts-emoji
  ```

</details>

<details>
  <summary><b>Installing hyprland, kitty and start desktop mode</b></summary>

  ```bash
    sudo pacman -S hyprland hyprlock kitty xdg-desktop-portal-hyprland
    rm -rf ~/.config/hyprland
    cp -r ~/Repos/dotfiles/hypr ~/.config/
    cp -r ~/Repos/dotfiles/kitty ~/.config/
    Hyprland #Super + R after to start kitty
  ```

</details>


## 2. Installing required softwares & packages

<details>
  <summary><b>Installing FastFetch</b></summary>

  ```bash
    sudo pacman -S fastfetch imagemagick
    cp ~/Repos/dotfiles/fastfetch ~/.config/
  ```

</details>

<details>
  <summary><b>Installing Thunar file browser (Super + E)</b></summary>

  ```bash
    sudo pacman -S thunar gvfs
  ```

</details>

<details>
  <summary><b>Installing VSCode (Super + C)</b></summary>

  ```bash
    yay -S visual-studio-code-bin
    cp ~/Repos/dotfiles/Code ~/.config/
    code --install-extension enkia.tokyo-night
  ```

</details>

<details>
  <summary><b>Installing Firefox (Super + F)</b></summary>

- Enable toolkit.legacyUserProfileCustomizations.stylesheets
- Copy <https://gist.github.com/khiem2794/4c8cd1e43c5bdf6c630cc314c55201e9>

  ```bash
    sudo pacman -S firefox
  ```

</details>

<details>
  <summary><b>Installing Waybar</b></summary>

  ```bash
    sudo pacman -S waybar
    cp ~/Repos/dotfiles/Code ~/.config/
  ```

</details>

<details>
  <summary><b>Installing Dunst</b></summary>

  ```bash
    sudo pacman -S dunst libnotify
    cp ~/Repos/dotfiles/dunst ~/.config/
  ```

</details>

<details>
  <summary><b>Installing Rofi (Super + A)</b></summary>

  ```bash
    yay -S rofi-lbonn-wayland-git
    cp ~/Repos/dotfiles/rofi ~/.config/
  ```

</details>

<details>
  <summary><b>Installing Wlogout (Super + [Shift] + Backspace)</b></summary>

  ```bash
    yay -S wlogout
    cp ~/Repos/dotfiles/wlogout ~/.config/
  ```

</details>

<details>
  <summary><b>Installing Swww</b></summary>

  ```bash
    yay -S swww
    mkdir ~/Pictures
    mkdir ~/Pictures/Wallpapers #Download and put wallpapers here
  ```

</details>

<details>
  <summary><b>Installing Warp VPN</b></summary>

  ```bash
    yay -S cloudflare-warp-bin 
    sudo systemctl enable warp-svc
    warp-cli connect
  ```

</details>

<details>
  <summary><b>Installing + Config Starship prompt</b></summary>

  ```bash
  sudo pacman -S starship
  echo "export STARSHIP_CONFIG=~/.config/starship/starship.toml" >> ~/.bashrc
  echo "eval \"\$(starship init bash)\"" >> ~/.bashrc
  rm ~/.config/starship.toml
  cp ~/Repos/dotfiles/starship ~/.config/
  ```

</details>

<details>
  <summary><b>Installing Tmux</b></summary>

  ```bash
    sudo pacman -S tmux
    cp ~/Repos/dotfiles/tmux ~/.config/
  ```

</details>

<details>
  <summary><b>Updating grub settings</b></summary>

  ```bash
    sudo nvim /etc/defaut/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
  ```

</details>

<details>
  <summary><b>Installing + Config SDDM</b></summary>

  ```bash
    sudo pacman -S sddm
    yay -S sddm-theme-corners-git
    sudo cp /usr/lib/sddm/sddm.conf.d/default.conf /etc/sddm.conf
    sudo nvim /etc/sddm.conf #change theme to corners
    sudo nvim /usr/share/sddm/themes/corners/theme.conf #change background
    sudo systemctl enable sddm 
  ```

</details>

<details>
  <summary><b>Installing TimeShift & Backup</b></summary>

  ```bash
    sudo pacman -S timeshift
    sudo -E timeshift-launcher
    sudo nvim /usr/share/applications/timeshift-gtk.desktop #fixing launcher
  ```

</details>

<details>
  <summary><b>Installing nvm</b></summary>

  ```bash
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    nvm install --lts
  ```

</details>

<details>
  <summary><b>Config neovim + install neovide</b></summary>

  ```bash
    git clone https:// github.com/khiem2794/nvim-config ~/.config/nvim
    sudo pacman -S neovide
  ```

</details>

<details>
  <summary><b>Installing screenshot tools (Super + P)</b></summary>

  ```bash
    sudo pacman -S slurp swappy cliphist
    yay -S grimblast-git
  ```

</details>

<details>
  <summary><b>Installing nwg-look</b></summary>

  ```bash
    sudo pacman -S nwg-look
    nwg-look
  ```

</details>

## 3. Resolve bugs might happen after

<details>
  <summary>1. Cursor theme not consistent</summary>

  Checking <https://wiki.archlinux.org/title/Cursor_themes#Configuration> and apply system-wide change.

</details>

## 4. Optional useful softwares & packages

<details>
  <summary><b>Chromium for running website headless</b></summary>

  ```bash
    sudo pacman -S chromium
    chromium --app=https://chat.openai.com
  ```

</details>

<details>
  <summary><b>Image viewer imv and Media player mpv</b></summary>

  ```bash
    sudo pacman -S imv mpv
  ```

</details>

<details>
  <summary><b>Pdf reader</b></summary>
</details>

<details>
  <summary><b>Image galery</b></summary>
</details>
