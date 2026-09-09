{ config, pkgs, pkgsUnstable, lib, herdr-nix, host, ... }:
let
  dotfilesPath = "/home/${host.user}/${host.dotfiles}";
in {
  imports = [
    ../../config/flameshot.nix
    ../../config/git.nix
    ../../config/lazygit.nix
    ../../config/mise.nix
  ];

  home.username = "${host.user}";
  home.homeDirectory = "/home/${host.user}";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    uv
    neovim tree-sitter fd gnumake gcc
    kitty ripgrep delta
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
    qt6.qtpositioning

  	herdr-nix.packages.${pkgs.system}.default
    pkgsUnstable.claude-code
    pkgsUnstable.opencode
    pkgsUnstable.codex
    pkgsUnstable.pi-coding-agent
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
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/${host.user}/${host.dotfiles}/config/nvim";
}
