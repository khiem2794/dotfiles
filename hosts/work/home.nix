{ config, pkgs, nixgl, ... }: {
	imports = [ ../../config/flameshot.nix ];

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
		eza
		(config.lib.nixGL.wrap zed-editor)
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
