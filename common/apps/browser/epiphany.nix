{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.epiphany;
in
{
  options.custom.apps.epiphany = {
    enable = mkEnableOption "GNOME Web";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.epiphany ];

    custom.system.persistence.userConfig = {
      directories = [ ".local/share/epiphany" ];
    };

    custom.system.home.extraOptions = {
      dconf.settings = {
        "org/gnome/epiphany" = {
          ask-for-default = false;
        };

        "org/gnome/epiphany/web" = {
          # general
          homepage-url = "about:newtab";
          ask-on-download = true;

          # privacy
          remember-passwords = false;
          autofill-data = false;
        };
      };
    };
  };
}
