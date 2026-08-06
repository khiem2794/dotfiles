{ pkgs, ... }: {
	imports = [ ];

	home.username = "khiemdn2";
	home.homeDirectory = "/home/khiemdn2";
	home.stateVersion = "26.05";

	targets.genericLinux.enable = true;
	programs.home-manager.enable = true;

	home.packages = with pkgs; [
		eza
	];
  home.file.".config/fastfetch".source = ./config/fastfetch;
}
