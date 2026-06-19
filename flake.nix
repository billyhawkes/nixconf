{
  description = "Personal Nix Configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rustfs = {
      url = "github:rustfs/rustfs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nix-darwin,
      nixpkgs,
      nvf,
      rustfs,
      sops-nix,
      ...
    }:
    {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nvf.nixosModules.default
            ./hosts/desktop/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
      };

      darwinConfigurations = {
        macbook = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit rustfs;
          };
          modules = [
            nvf.darwinModules.default
            ./hosts/macbook/configuration.nix
          ];
        };
      };
    };
}
