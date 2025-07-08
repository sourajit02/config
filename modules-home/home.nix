{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  # home.username = "s";
  # home.homeDirectory = /users/s/state;
  home.preferXdgDirectories = true;
  # home.profileDirectory = "/users/s/state";
  # home.sessionVariables = {
  #   HOME_MANAGER_CONFIG = "/users/s/config";
  # };
  # nix.settings.use-xdg-base-directories = true; # This will use XDG directories
  # xdg = {
  #   enable = true;
  #   configHome = /users/s/state/.config;
  #   cacheHome = /users/s/state/cache;
  #   dataHome = /users/s/home/.local/share;
  #   stateHome = /users/s/home/.local/state;
  # };
  programs.nushell = {
    enable = true;
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
  programs.yazi = {
    enable = true;
  };
  programs.alacritty = {
    enable = true;
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "autumn_night_transparent";
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
    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
  };

  # programs.nushell = {
  #   enable = true;
  #   configFile.text = ''
  #     # Set HOME to the clean home directory after nushell loads
  #     $env.HOME = "/users/s/home"

  #     # Launch Niri if no display is set (console login)
  #     if ($env.DISPLAY? | is-empty) {
  #       cd $env.HOME
  #       niri
  #     }
  #   '';

  #   envFile.text = ''
  #     # Initial HOME for nushell to load its config
  #     $env.HOME = "/users/s/home"
  #     # Set other XDG directories
  #     $env.XDG_CONFIG_HOME = "/users/s/config"
  #     $env.XDG_CACHE_HOME = "/users/s/config/cache"
  #     $env.XDG_DATA_HOME = "/users/s/config/local/share"
  #     $env.XDG_STATE_HOME = "/users/s/config/local/state"
  #   '';
  # };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
}
