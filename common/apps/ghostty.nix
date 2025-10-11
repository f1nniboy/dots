{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.apps.ghostty;
in
{
  options.custom.apps.ghostty = {
    enable = mkEnableOption "Ghostty terminal";
  };

  config = mkIf cfg.enable {
    custom.system.home.extraOptions = {
      programs.ghostty = {
        enable = true;

        enableBashIntegration = true;

        settings = {
          theme = "Adwaita Dark";

          font-family = "FiraCode Nerd Font";
          font-size = 11;
          bold-color = "bright";

          window-padding-x = 5;
          window-padding-y = 5;

          window-width = 105;
          window-height = 32;

          desktop-notifications = false;
        };
      };
    };
  };
}
