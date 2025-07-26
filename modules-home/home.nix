{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.niri.homeModules.niri # nixpkgs version has no home-manager intergration, so use flake
    inputs.zen-browser.homeModules.beta
  ];

  home.stateVersion = "25.11";
  #############################

  home.packages = with pkgs; [
    swaybg
    xwayland-satellite
    mako
    trash-cli
    restic

    krita
    libqalculate
    wttrbar

    # hunspell
    # hunspellDicts.en_AU
    # languagetool-rust
    # js-beautify
    # ltex-ls-plus # not many users?
    # bibtex-tidy
    # jdtls
    # dockfmt
    # cmake-language-server
    # markdownlint-cli
    # rich-cli
    # ruff
    # simple-completion-language-server
    markdown-oxide
    dprint
    basedpyright

    # mujoco
    # ouch
    # ocenaudio # checksum mismatch???
    bottles # older than bottles-unwrapped package?
    clblast
    deadbeef-with-plugins
    legcord
    gimp3-with-plugins
    gpu-screen-recorder-gtk
    hd-idle
    hugin
    imgbrd-grabber
    libreoffice
    losslesscut-bin
    media-downloader
    mousai
    mpc
    mpvScripts.thumbfast # there are others
    nvtopPackages.amd
    osu-lazer-bin
    pavucontrol
    pdfarranger
    qbittorrent-enhanced-nox
    rnote
    sigil
    simple-completion-language-server
    simple-scan
    wev
    wootility
    # wootility-udev-rules
    zotero
  ];

  # this section literally does not have any effect on wayland for the time being, see [this](https://github.com/nix-community/home-manager/issues/1011)
  home.sessionVariables = {
    EDITOR = "hx";
  };

  programs.home-manager.enable = true;

  programs.yazi = {
    enable = true;
  };
  programs.zen-browser = {
    enable = true;
  };
  programs.uv = {
    enable = true;
  };
  programs.obs-studio = {
    enable = true;
  };
  programs.mpv = {
    enable = true;
  };
  programs.fastfetch = {
    enable = true;
  };
  programs.btop = {
    enable = true;
  };
  programs.zellij = {
    enable = true;
  };
  programs.zed-editor = {
    enable = true;
  };
  programs.ghostty = {
    enable = true;
  };
  programs.qutebrowser = {
    enable = true;
  };
  programs.zathura = {
    enable = true;
  };

  services.mpd = {
    enable = true;
    musicDirectory = "~/media/audio/";
  };
  programs.rmpc = {
    enable = true;
  };
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        horizontal-pad = 8;
      };
      border = {
        width = 0;
        radius = 0;
      };
    };
  };
  programs.waybar = {
    enable = true;
    systemd.enable = true; # disable if bar is not visible
    settings = {
      # this can be named anything? only important if having multiple bars
      mainBar = {
        layer = "top";
        position = "bottom";
        spacing = 0;
        fixed-center = false;
        # reload_style_on_change = true;

        modules-left = [
          "niri/workspaces"
          # "wlr/taskbar"
          "mpd"
          "tray"
        ];
        modules-right = [
          "memory"
          "disk"
          # "disk#ssd"
          "temperature"
          "custom/weather"
          "clock"
        ];
        # "niri/workspaces" = {
        # };
        # "wlr/taskbar" = {
        # };
        "custom/weather" = {
          format = "{}°";
          tooltip = true;
          interval = 1800;
          exec = "wttrbar";
          return-type = "json";
        };

      };
    };
    style = ''
      * {
      	border: none;
      	border-radius: 0;
      	font-family: "monospace";
      	min-height: 0;
      	font-size: 1.015em;
      	font-weight: 600;
      	padding: 0 0px;
      }             
    '';
  };
  programs.nushell = {
    enable = true;
    extraConfig = ''
      def nrs [] {
            cd /home/s/test/config
            # git pull
            sudo nixos-rebuild switch --flake
            # reboot
          }
    '';
    environmentVariables = {
      EDITOR = "hx";
    };
    settings = {
      show_banner = false;
      completions.external = {
        enable = true;
        max_results = 200;
      };
      history.max_size = 1000000;
      history.sync_on_enter = true;
      history.file_format = "sqlite";
      history.isolation = false;
    };
  };

  programs.helix = {
    enable = true;
    settings = {
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
    };
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
      }
    ];
  };

  # wayland compositor settings
  programs.niri = {
    enable = true;
    settings = {
      environment = {
        QT_QPA_PLATFORM = "wayland";
        EDITOR = "hx"; # will not work in tty, remember niri has to spawn nushell
      };
      spawn-at-startup = [
        { command = [ "waybar" ]; }
        {
          command = [
            "swaybg"
            "--image"
            "${config.stylix.image}"
          ];
        }
        # { command = [ "~/.config/niri/scripts/startup.sh" ]; }
      ];
      hotkey-overlay = {
        skip-at-startup = true;
      };
      prefer-no-csd = true;
      environment."NIXOS_OZONE_WL" = "1";
      layout = {
        gaps = 4;
        border.width = 4;
      };
      input = {
        keyboard = {
          repeat-delay = 250;
          repeat-rate = 50;
          xkb = {
            layout = "us";
            variant = "colemak";
            # options = "compose:ralt,ctrl:backspace";
          };
        };
      };

      binds = with config.lib.niri.actions; {
        "Mod+Return".action = spawn "ghostty";
        "Mod+N".action = spawn "ghostty -e yazi";
        "Mod+R".action = spawn "fuzzel";
        "Mod+C".action = close-window;
        # "Mod+D".action = spawn "rofi -show combi -modes combi -combi-modes \"drun,window\" -show-icons";
      };
    };
  };

  services.restic = {
    enable = true; # only available in home-manager restic
    backups = {
      localbackup = {
        exclude = [
        ];
        initialize = false;
        passwordFile = "/etc/nixos/secrets/restic-password";
        paths = [
          "/persist"
        ];
        repository = "/mnt/backup-hdd";
      };
      # remotebackup = {
      #   extraOptions = [
      #     "sftp.command='ssh backup@host -i /etc/nixos/secrets/backup-private-key -s sftp'"
      #   ];
      #   passwordFile = "/etc/nixos/secrets/restic-password";
      #   paths = [
      #     "/home"
      #   ];
      #   repository = "sftp:backup@host:/backups/home";
      #   timerConfig = {
      #     OnCalendar = "00:05";
      #     RandomizedDelaySec = "5h";
      #   };
      # };
    };
  };

}
