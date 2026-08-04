{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Asia/Ho_Chi_Minh";

  networking.hostName = "t14";
  networking.networkmanager.enable = true;
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  users.users.khiem2794 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [
      tree
    ];
  };

  # services.xserver.enable = true;

  services.getty.autologinUser = "khiem2794";
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    kitty
    networkmanager
    brightnessctl
    libnotify
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "26.05";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}

