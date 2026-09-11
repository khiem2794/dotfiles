{ config, pkgs, pkgsUnstable, nixgl, herdr-nix, host, ... }:
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

	targets.genericLinux.enable = true;
	programs.home-manager.enable = true;

	targets.genericLinux.nixGL = {
		packages = nixgl.packages;
		defaultWrapper = "mesa";
	};

	home.packages = with pkgs; [
		uv tig
		neovim ripgrep delta eza tree-sitter
		(config.lib.nixGL.wrap zed-editor)
		(config.lib.nixGL.wrap kitty)
		(config.lib.nixGL.wrap obsidian)
		herdr-nix.packages.${pkgs.system}.default
 
		pkgsUnstable.claude-code
    pkgsUnstable.opencode
    pkgsUnstable.codex
    pkgsUnstable.pi-coding-agent
	];

	services.flameshot.package = config.lib.nixGL.wrap pkgs.flameshot;

	home.file.".config/quickshell".source =
		config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/quickshell";
	home.file.".config/kitty".source =
		config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/kitty";
	home.file.".config/zellij".source = ../../config/zellij;
	home.file.".config/fastfetch".source = ../../config/fastfetch;
	  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/nvim";

	home.file.".config/hypr/hyprland.lua".source =
		config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/hypr/hyprland.lua";
	home.file.".config/hypr/hyprpaper.conf".source =
		config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/hypr/hyprpaper.conf";
	home.file.".config/hypr/qs-dms.lua".source =
		config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/hypr/qs-dms.lua";
	home.file.".config/hypr/qs-noctalia.lua".source =
		config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/hypr/qs-noctalia.lua";
	home.file.".config/hypr/assets".source =
		config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/hypr/assets";
	home.file.".config/hypr/var.lua".source =
		config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/hosts/${host.dir}/hypr/var.lua";
	home.file.".config/hypr/env.lua".source =
		config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/hosts/${host.dir}/hypr/env.lua";
}
