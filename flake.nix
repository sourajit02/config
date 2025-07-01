{
  description = "test config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs =
    { self, nixpkgs }:
    {

      # Please replace my-nixos with your hostname
      nixosConfigurations.hbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./configurations.nix ];
      };
    };
}
