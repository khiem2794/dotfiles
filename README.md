<h1 align=center>NixOS Hyprland Dotfiles</h1>

<div align="center">
<a href="#layout">Layout</a> - <a href="#setup">Setup</a> - <a href="#new-host">New host</a>
</div>

---

<h2 id="layout">1. Layout</h2>

  ```
    flake.nix                 # builds one config from config/_host.nix
    config/_host.example.nix  # template for the local host file
    config/_host.nix          # local host file (git-ignored)
    config/                   # shared configs: hypr, quickshell, kitty, nvim, git, lazygit, mise, ...
    hosts/<dir>/
      configuration.nix       # NixOS system (nixos hosts only)
      hardware-configuration.nix
      home.nix                # home-manager: packages and dotfile links
      hypr/var.lua, env.lua   # per-host Hyprland variables
  ```

  Hosts:
  - `tbx`, `t14`: NixOS + home-manager module
  - `work`: standalone home-manager on a non-NixOS distro (GUI apps wrapped with nixGL)

<h2 id="setup">2. Setup</h2>

  ```bash
    git clone <repo> ~/Repos/dotfiles && cd ~/Repos/dotfiles

    # Create the local host config, then fill it in
    # type = "home" -> homeConfigurations, otherwise nixosConfigurations
    cp config/_host.example.nix config/_host.nix

    # config/_host.nix is untracked, so use a path: flake reference, not .#
    sudo nixos-rebuild switch --flake path:.#<hostname>  # type = "nixos"
    home-manager switch --flake path:.#<hostname>        # type = "home"

    # First run of home-manager, before it is installed
    nix run home-manager/release-26.05 -- switch --flake path:.#<hostname>
  ```

  Configs linked with `mkOutOfStoreSymlink` (nvim, kitty, hypr, ...) point at the repo, so edits apply without a rebuild. `dotfiles` in `_host.nix` must match the clone location relative to `$HOME`.

<h2 id="new-host">3. Adding a new host</h2>

  - Copy an existing `hosts/<dir>/` that matches the type (`tbx` for NixOS, `work` for home-manager).
  - NixOS: replace `hardware-configuration.nix` with the one from `/etc/nixos/`, and set `networking.hostName` and the user in `configuration.nix`.
  - Set `dir` in `config/_host.nix` to the new folder name.
