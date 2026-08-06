{ config, pkgs, lib, ... }: { 
  home.username = "khiem2794";
  home.homeDirectory = "/home/khiem2794";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    fastfetch imv mpv
    zellij lazygit brave yazi flameshot vscode
    playerctl
    nerd-fonts.jetbrains-mono
    material-symbols
    hyprpaper
    imagemagick
    quickshell
    qt6.qtsvg
    qt6.qtimageformats
    qt6.qt5compat
    qt6.qtmultimedia
    qt6.qtdeclarative
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
    };
  };
  
  programs.starship = {
    enable = true;
  };

  home.file.".config/fastfetch".source = ./config/fastfetch;
  home.file.".config/hypr".source = ./config/hypr;
  home.file.".config/quickshell".source = ./config/quickshell;
  home.file.".config/kitty".source = ./config/kitty;
  home.file.".config/flameshot".source = ./config/flameshot;
  home.file.".config/zellij".source = ./config/zellij;
}
