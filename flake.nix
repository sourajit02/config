{
  description = "test config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      nixpkgs,
      disko,
      ...
    }:
    {

      # run this
      # nix run github:nix-community/nixos-anywhere -- --flake .#hbox --generate-hardware-config nixos-generate-config ./hosts/hbox/hardware-configuration.nix hbox
      nixosConfigurations.hbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./hosts/hbox/configuration.nix
          ./hosts/hbox/hardware-configuration.nix
        ];
      };
    };
}
