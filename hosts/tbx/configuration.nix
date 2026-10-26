{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  time.timeZone = "Asia/Ho_Chi_Minh";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "tbx";
  networking.networkmanager.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "vi_VN";
    LC_IDENTIFICATION = "vi_VN";
    LC_MEASUREMENT = "vi_VN";
    LC_MONETARY = "vi_VN";
    LC_NAME = "vi_VN";
    LC_NUMERIC = "vi_VN";
    LC_PAPER = "vi_VN";
    LC_TELEPHONE = "vi_VN";
    LC_TIME = "vi_VN";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users."khiem2794" = {
    isNormalUser = true;
    description = "khiem";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

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

  programs.dconf.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      libffi
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim wget git unzip
    networkmanager
    brightnessctl
    libnotify
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  system.stateVersion = "26.05";
}
