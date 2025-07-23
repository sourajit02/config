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
    # inputs.zen-browser.homeModules.beta
  ];

  home.packages = with pkgs; [
    swaybg
    xwayland-satellite
    mako
    trash-cli

    krita
    libqalculate
  ];

  programs.home-manager.enable = true;

  programs.yazi = {
    enable = true;
  };
  programs.firefox = {
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
    musicDirectory = "~/media/audio/"; # right path?
    network.startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket
    # extraConfig = ''
    #   # must specify one or more outputs in order to play audio!
    #   # (e.g. ALSA, PulseAudio, PipeWire), see next sections
    # '';
    # network.listenAddress = "any"; # if you want to allow non-localhost connections
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
        reload_style_on_change = true;

        modules-left = [
          # "niri/workspaces"
          "tray"
          "mpd"
        ];
        modules-right = [
          "memory"
          "disk"
          # "disk#ssd"
          "temperature"
          # "weather"
          "clock"
        ];
        # "niri/workspaces" = {
        #   # icon-size = 12;
        # };

      };
    };
    # style = '''';
  };
  programs.nushell = {
    enable = true;
    extraConfig = ''
      def nrs [] {
            cd /home/s/config
            git pull
            sudo nixos-rebuild switch --flake
            reboot
          }
    '';
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

  home.sessionVariables = {
    XKB_DEFAULT_LAYOUT = "us";
    XKB_DEFAULT_VARIANT = "colemak";
    # QT_QPA_PLATFORM = "wayland;xcb";
  };
  ## do not touch
  home.stateVersion = "25.11";
}
