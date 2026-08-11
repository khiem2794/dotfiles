{ config, pkgs, lib, ... }: {
  imports = [ ../../config/flameshot.nix ];

  home.username = "khiem2794";
  home.homeDirectory = "/home/khiem2794";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    fastfetch imv mpv
    zellij lazygit brave yazi vscode
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

  home.file.".config/hypr" = {
    source = ../../config/hypr;
    recursive = true;
  };
  home.file.".config/hypr/var.lua".source = ./hypr/var.lua;
  home.file.".config/hypr/env.lua".source = ./hypr/env.lua;
  home.file.".config/quickshell".source = ../../config/quickshell;
  home.file.".config/kitty".source = ../../config/kitty;
  home.file.".config/zellij".source = ../../config/zellij;
  home.file.".config/fastfetch".source = ../../config/fastfetch;
}
