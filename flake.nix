{
	description = "NixOS Hyprland";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-26.05";

		home-manager = {
			url = "github:nix-community/home-manager/release-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, home-manager, ... }:
		let
			system = "x86_64-linux";
			pkgs = import nixpkgs {
				inherit system;
				config.allowUnfree = true;
			};
		in {
			nixosConfigurations.t14 = nixpkgs.lib.nixosSystem {
				inherit system;
				modules = [
					./configuration.nix

					home-manager.nixosModules.home-manager
					{
						home-manager = {
							useGlobalPkgs = true;
							useUserPackages = true;
							users.khiem2794 = import ./home-t14.nix;
							backupFileExtension = "backup";
						};
					}
				];
			};

			homeConfigurations.work = home-manager.lib.homeManagerConfiguration {
				inherit pkgs;
				modules = [ ./home-work.nix ];
			};
		};
}
