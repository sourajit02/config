{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
    ./disks.nix
  ];

  users.users.root.initialHashedPassword = "";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "hbox";
  networking.networkmanager.enable = true;
  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  time.timeZone = "Australia/Sydney";
  console.keyMap = "colemak";
  services.xserver = {
    enable = true;
    # displayManager.gdm.enable = true;
    xkb = {
      layout = "us";
      variant = "colemak";
    };
  };
  system.copySystemConfiguration = true;
  services.openssh.enable = true;
  programs.firefox.enable = true;
  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.systemPackages = with pkgs; [
    git # order matters, so git is first
    wget
    neovim
    helix
    niri
  ];
  programs.niri.enable = true;
  hardware.graphics.enable = true; # vm issues?
  # Set the default editor to vim
  environment.variables.EDITOR = "helix";

  system.stateVersion = "25.11"; # never change this
}
