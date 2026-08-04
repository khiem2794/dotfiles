{ config, pkgs, ... }: { 
  home.username = "khiem2794";
  home.homeDirectory = "/home/khiem2794";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    fastfetch
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
  
  home.file.".config/hypr".source = ./config/hypr;
  home.file.".config/quickshell".source = ./config/quickshell;
}
