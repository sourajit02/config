{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "s";
  # home.homeDirectory = "/users/s/home";
  # home.profileDirectory = "/users/s/config";
  # home.sessionVariables = {
  #   HOME_MANAGER_CONFIG = "/users/s/config";
  # };
  xdg = {
    enable = true;
    configHome = "/users/s/config";
    cacheHome = "/users/s/state/cache";
    dataHome = "/users/s/state/local/share";
    stateHome = "/users/s/state/local/state";
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
