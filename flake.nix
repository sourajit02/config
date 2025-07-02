{
  description = "test config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      # home-manager,
      # disko,
      ...
    }@inputs:
    {
      nixosConfigurations.hbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # disko.nixosModules.disko
          ./configuration.nix
          ./hardware-configuration.nix
          ./disks.nix
        ];
      };
    };
}
