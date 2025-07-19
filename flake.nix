{
  description = "NixOS configs";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    preservation.url = "github:nix-community/preservation";

    sops-nix.url = "github:mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      self,
      nixpkgs,
      niri,
      stylix,
      ...
    }@inputs:
    {
      nixosConfigurations.hbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; }; # pass inputs to the modules below
        modules = with inputs; [
          ./hosts/hbox/configuration.nix
          ./hosts/hbox/hardware-configuration.nix
          disko.nixosModules.disko
          preservation.nixosModules.preservation
          stylix.nixosModules.stylix # home-manager module bundled with nixos module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true; # install packages to /etc/profiles
            home-manager.backupFileExtension = "backup";
            home-manager.users.s = ./modules-home/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };

          }
        ];
      };
    };
}
