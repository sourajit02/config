{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ./disks.nix
  ];

  system.stateVersion = "25.11"; # never change this
  users.users.root.initialPassword = "password"; # install-script will prompt change for root and s
  security.sudo.wheelNeedsPassword = false;
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
    displayManager.startx.enable = true;
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

  users.users.s = {
    home = "/users/s";
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
    ];
    createHome = false;
  };

  # transfer ownership to s
  systemd.tmpfiles.settings = {
    "10-give-s-ownership" = {
      "/users/s/home" = {
        # Z for recursive
        z = {
          group = "root";
          # mode = "0700";
          user = "s";
        };
      };
      "/users/s/config" = {
        # Z for recursive
        z = {
          group = "root";
          # mode = "0700";
          user = "s";
        };
      };
    };
  };
}
