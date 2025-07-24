{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    # ./hardware-configuration.nix
    ./disks.nix
    inputs.ucodenix.nixosModules.default
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "25.11"; # never change this
  ############################

  # check if this works on real hardware
  # sudo dmesg | grep microcode
  # https://github.com/e-tho/ucodenix
  services.ucodenix.enable = true;

  hardware = {
    amdgpu.overdrive.ppfeaturemask = "0xffffffff";
    # cpu.amd.updateMicrocode = true; # ucodenix flake provides actual updates for non-server cpus
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
  };
  users.users.root.initialHashedPassword = "$y$j9T$LgZNfZgC.jlSpJHuYdWJW1$YcJSBxMF.9rWLb5ijXRKyoSJgfc6HWNdMlRkUxl1yND";
  security.sudo.wheelNeedsPassword = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 2;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 20;

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    settings.auto-optimise-store = true;
  };

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

  services.miniflux = {
    enable = true;
    adminCredentialsFile = "/home/s/config/secrets/miniflux";
  };

  # services.suwayomi-server = {
  #   enable = true;
  #   dataDir = "/home/s/manga"; # move to /home/s/media/manga once space permits
  #   package = pkgs.suwayomi-server.overrideAttrs (old: rec {
  #     version = "2.0.1727";
  #     src = pkgs.fetchurl {
  #       url = "https://github.com/Suwayomi/Suwayomi-Server/releases/download/v${version}/Suwayomi-Server-v${version}.jar";
  #       hash = "sha256-+nq9/uQ/3Xjyj8oKiXrTF34y7Ig/I95spRWjwPP7+Uw=";
  #     };
  #     buildPhase = ''
  #       runHook preBuild
  #       makeWrapper ${pkgs.jdk21_headless}/bin/java $out/bin/tachidesk-server \
  #         --add-flags "-Dsuwayomi.tachidesk.config.server.initialOpenInBrowserEnabled=false -jar $src"
  #       runHook postBuild
  #     '';
  #   });

  #   settings.server = {
  #     port = 4567;
  #     downloadAsCbz = true;
  #     extensionRepos = [
  #       "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
  #     ];
  #   };
  # };

  programs.yazi = {
    enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    git # order matters, so git is first
    curl
    wget
    lact
    helix
    nushell
    suwayomi-server # only needed for now to override version
  ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];

  zramSwap = {
    enable = true;
  };
  # services.swapspace = {
  #   enable = true;
  #   settings = {
  #     max_swapsize = "64g";
  #     swappath = "/swapspace";
  #   };
  # };

  environment.variables = {
    EDITOR = "helix";
    AMD_VULKAN_ICD = "RADV";
  };

  users.mutableUsers = false;
  users.users.s = {
    home = "/home/s";
    isNormalUser = true;
    initialHashedPassword = "$y$j9T$LgZNfZgC.jlSpJHuYdWJW1$YcJSBxMF.9rWLb5ijXRKyoSJgfc6HWNdMlRkUxl1yND";
    shell = pkgs.nushell;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
    ];
    createHome = true;
  };

  boot.kernelParams = [
    "amdgpu"
    "microcode.amd_sha_check=off"
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr.icd
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };

  ## are these needed?
  # boot.initrd.kernelModules = [ "amdgpu" ];
  # systemd.tmpfiles.rules =
  #   let
  #     rocmEnv = pkgs.symlinkJoin {
  #       name = "rocm-combined";
  #       paths = with pkgs.rocmPackages; [
  #         rocblas
  #         hipblas
  #         clr
  #       ];
  #     };
  #   in
  #   [
  #     "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  #   ];
  #
  boot.initrd.systemd.enable = true;
  preservation = {
    enable = true;
    preserveAt."/persist" = {
      directories = [
        "/etc/secureboot"
        "/var/lib/bluetooth"
        "/var/lib/fprint"
        "/var/lib/fwupd"
        "/var/lib/libvirt"
        "/var/lib/power-profiles-daemon"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/rfkill"
        "/var/lib/systemd/timers"
        # miniflux db location here
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
      ];
      files = [
        "/var/lib/usbguard/rules.conf"
        {
          file = "/etc/machine-id";
          inInitrd = true;
          how = "symlink";
          configureParent = true;
        }

        {
          file = "/etc/ssh/ssh_host_rsa_key";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          configureParent = true;
        }

      ];

      users.s = {
        commonMountOptions = [
          "x-gvfs-hide"
        ];
        # make sure not to delete these mounted folders or nothing inside will get persisted.
        # ie copy over downloads/* into downloads instead of downloads into home/s
        directories = [
          "config"
          "courses"
          "documents"
          "downloads"
          "games"
          "manga"
          # no media, is mounted on separate drive so won't be wiped anyway
          "notes"
          "photos"
          "projects"
          "reading"
          "sitar"
          "work"

          ".zen"
          {
            directory = ".ssh";
            mode = "0700";
          }
        ];
        files = [
          {
            file = ".config/nushell/history.sqlite3";
            how = "symlink";
          }

        ];
      };
    };

  };

  # add directories here to set permissions correctly
  systemd.tmpfiles.settings.preservation = {
    "/home/s/.config".d = {
      user = "s";
      group = "users";
    };
    "/home/s/.local".d = {
      user = "s";
      group = "users";
    };
    # "/home/s/.local/share".d = {
    #   user = "s";
    #   group = "users";
    # };
    # "/home/s/.local/state".d = {
    #   user = "s";
    #   group = "users";
    # };
  };

  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      # ""
      "/persistent/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      # ""
      "systemd-machine-id-setup --commit --root /persistent"
    ];
  };

  fonts.packages = with pkgs; [
    #######
    ### This is incomplete, just here to check build ability
    (iosevka.override {
      set = "term";
      privateBuildPlan = {
        family = "IosevkaMonoSans";
        spacing = "term"; # "term" to make symbols like 🅇 actually fit in one space
        serifs = "sans";
        noCvSs = true;
        exportGlyphNames = true;
        buildTextureFeature = true;
        # dunno if this does anything
        hintParams = [
          "-a"
          "qqq"
        ];
        metricOverride = {
          xHeight = 548; # height of x, a etc
          leading = 1100; # line height
          dotSize = "blend(weight, [425, 140], [600, 170])"; # size of dots in diacritics 125 default
          periodSize = "blend(weight, [425, 180], [600, 200])"; # size of period and comma, 140 default

        };
        # this is a width, set to 548 for better spacing between letters
        widths.Normal = {
          shape = 548;
          menu = 5;
          css = "normal";
        };
      };
    })

  ];

  stylix = {
    enable = true;

    # disable after nixos-anywhere install, trusted signature lacking error for autogeneration pallete code
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

    polarity = "dark"; # bias
    image = pkgs.fetchurl {
      url = "https://4kwallpapers.com/images/wallpapers/genshin-impact-5120x2880-22945.jpg";
      hash = "sha256-G4L4vFOTeXFXeoV5/6r0PYHyIlGdYNxvYubLO1GCkbM=";
    };
    # image = pkgs.fetchurl {
    #   url = "https://4kwallpapers.com/images/wallpapers/cha-hae-in-5k-solo-5120x2880-21907.jpg";
    #   hash = "sha256-LR3RV1yVS/YaNGdM5dB7klvJ3BYDEGOMgQSMLIu52eU=";
    # };
    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.iosevka;
        name = "IosevkaMonoSans";
      };

      monospace = {
        package = pkgs.iosevka;
        name = "IosevkaMonoSans";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  ## accessed at localhost:28981
  # environment.etc."paperless-admin-pass".text = "admin";
  # services.paperless = {
  #   enable = true;
  #   passwordFile = "/etc/paperless-admin-pass";
  #   settings = {
  #     PAPERLESS_DBHOST = "localhost";
  #     PAPERLESS_CONSUMER_IGNORE_PATTERN = [
  #       ".DS_STORE/*"
  #       "desktop.ini"
  #     ];
  #     PAPERLESS_OCR_LANGUAGE = "eng";
  #     PAPERLESS_OCR_USER_ARGS = {
  #       optimize = 1;
  #       pdfa_image_compression = "lossless";
  #     };

  #   };

  # };

}
