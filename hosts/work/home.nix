{ config, pkgs, nixgl, ... }: {
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
		ripgrep delta eza
		(config.lib.nixGL.wrap zed-editor)
		(config.lib.nixGL.wrap kitty)
		(config.lib.nixGL.wrap foot)
		(config.lib.nixGL.wrap obsidian)
	];

	services.flameshot.package = config.lib.nixGL.wrap pkgs.flameshot;

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
