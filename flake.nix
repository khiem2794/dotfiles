{
	description = "NixOS Hyprland";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-26.05";
		nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

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

	outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixgl, herdr-nix, ... }:
		let
			hosts = import ./config/_hosts.nix;

			pkgsUnstable = system: import nixpkgs-unstable {
				system = system;
				config.allowUnfree = true;
			};

			mkHomeConfiguration = host:
				home-manager.lib.homeManagerConfiguration {
					pkgs = import nixpkgs {
						system = host.arch;
						config.allowUnfree = true;
					};
					extraSpecialArgs = {
						inherit host nixgl herdr-nix;
						pkgsUnstable = pkgsUnstable host.arch;
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
								extraSpecialArgs = {
									inherit host herdr-nix;
									pkgsUnstable = pkgsUnstable host.arch;
								};
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
