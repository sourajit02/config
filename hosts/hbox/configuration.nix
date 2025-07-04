{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    # ./hardware-configuration.nix
    ./disks.nix
  ];

  system.stateVersion = "25.11"; # never change this
  users.users.root.initialPassword = "password"; # install-script will prompt change for root and s
  security.sudo.wheelNeedsPassword = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Limit the number of generations to keep
  boot.loader.systemd-boot.configurationLimit = 10;
  # Perform garbage collection weekly to maintain low disk usage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  # Optimize storage
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;

  nix.nixPath = [ "/users/s/config/nixcfg" ];
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
  # system.copySystemConfiguration = true; # cannot be used with nixos-anywhere
  services.openssh.enable = true;
  programs.firefox.enable = true;
  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.systemPackages = with pkgs; [
    git # order matters, so git is first
    curl
    wget
    helix
    nushell
    niri
  ];
  programs.niri.enable = true;
  # programs.nushell.enable = true;
  hardware.graphics.enable = true; # vm issues?
  # Set the default editor to vim
  environment.variables.EDITOR = "helix";

  users.users.s = {
    # we change this to /users/s/home after login but before wm starts.
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
