{
	description = "NixOS Hyprland";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-26.05";

		home-manager = {
			url = "github:nix-community/home-manager/release-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nixgl = {
			url = "github:nix-community/nixGL";
			inputs.nixpkgs.follows = "nixpkgs";
		};

        herdr-nix = {
            url = "github:herdrdev/herdr-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
	};

	outputs = { self, nixpkgs, home-manager, nixgl, ... }:
		let
			hosts = import ./config/_hosts.nix;

			mkHomeConfiguration = host:
				home-manager.lib.homeManagerConfiguration {
					pkgs = import nixpkgs {
						system = host.arch;
						config.allowUnfree = true;
					};
					extraSpecialArgs = {
						inherit host nixgl;
					};
					modules = [
						./hosts/${host.dir}/home.nix
					];
				};

			mkNixOSConfiguration = host:
				nixpkgs.lib.nixosSystem {
					system = host.arch;
					modules = [
						./hosts/${host.dir}/configuration.nix
						home-manager.nixosModules.home-manager
						{
							home-manager = {
								useGlobalPkgs = true;
								useUserPackages = true;
								extraSpecialArgs = { inherit host; };
								users."${host.user}" = import ./hosts/${host.dir}/home.nix;
								backupFileExtension = "backup";
							};
						}
					];
				};
		in {
			nixosConfigurations."${hosts.t14.hostname}" =
				mkNixOSConfiguration hosts.t14;

			homeConfigurations."${hosts.work.hostname}" =
				mkHomeConfiguration hosts.work;
		};
}
