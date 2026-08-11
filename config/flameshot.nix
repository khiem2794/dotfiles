{ config, ... }: {
	services.flameshot = {
		enable = true;
		settings = {
			General = {
				savePath = "${config.home.homeDirectory}/Pictures/Screenshots";
				showHelp = false;
				useGrimAdapter = true;
				saveAsFileExtension = "png";
			};
		};
	};
}
