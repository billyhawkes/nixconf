{
  description = "Personal NixOS Desktop Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/desktop/configuration.nix ];
        };
      };

      homeConfigurations = {
        billy = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home/billy.nix ];
        };
      };
    };
}