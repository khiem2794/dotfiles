{ config, pkgs, nixgl, host, ... }: {
	imports = [
		../../config/flameshot.nix
		../../config/git.nix
		../../config/lazygit.nix
	];

	home.username = "khiemdn2";
	home.homeDirectory = "/home/khiemdn2";
	home.stateVersion = "26.05";

	targets.genericLinux.enable = true;
	programs.home-manager.enable = true;

	targets.genericLinux.nixGL = {
		packages = nixgl.packages;
		defaultWrapper = "mesa";
	};

	home.packages = with pkgs; [
		neovim ripgrep delta eza tree-sitter
		(config.lib.nixGL.wrap zed-editor)
		(config.lib.nixGL.wrap kitty)
		(config.lib.nixGL.wrap obsidian)
	];

	services.flameshot.package = config.lib.nixGL.wrap pkgs.flameshot;

	home.file.".config/quickshell".source = ../../config/quickshell;
	home.file.".config/kitty".source = ../../config/kitty;
	home.file.".config/zellij".source = ../../config/zellij;
	home.file.".config/fastfetch".source = ../../config/fastfetch;
  	home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink /home/${host.user}/Repos/dotfiles/config/nvim;

	home.file.".config/hypr/hyprland.lua".source =
		config.lib.file.mkOutOfStoreSymlink "/home/${host.user}/Repos/dotfiles/config/hypr/hyprland.lua";
	home.file.".config/hypr/hyprpaper.conf".source =
		config.lib.file.mkOutOfStoreSymlink "/home/${host.user}/Repos/dotfiles/config/hypr/hyprpaper.conf";
	home.file.".config/hypr/qs-dms.lua".source =
		config.lib.file.mkOutOfStoreSymlink "/home/${host.user}/Repos/dotfiles/config/hypr/qs-dms.lua";
	home.file.".config/hypr/qs-noctalia.lua".source =
		config.lib.file.mkOutOfStoreSymlink "/home/${host.user}/Repos/dotfiles/config/hypr/qs-noctalia.lua";
	home.file.".config/hypr/assets".source =
		config.lib.file.mkOutOfStoreSymlink "/home/${host.user}/Repos/dotfiles/config/hypr/assets";
	home.file.".config/hypr/var.lua".source =
		config.lib.file.mkOutOfStoreSymlink "/home/${host.user}/Repos/dotfiles/hosts/${host.dir}/hypr/var.lua";
	home.file.".config/hypr/env.lua".source =
		config.lib.file.mkOutOfStoreSymlink "/home/${host.user}/Repos/dotfiles/hosts/${host.dir}/hypr/env.lua";
}
