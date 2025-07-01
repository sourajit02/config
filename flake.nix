{
  description = "test config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    disko.url = "github:nix-community/disko";
  };
  outputs =
    {
      self,
      nixpkgs,
      disko,
      ...
    }:
    {

      # Please replace my-nixos with your hostname
      nixosConfigurations.hbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          disko.nixosModules.disko
          # ./hardware-configuration.nix
        ];
      };
    };
}
