{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.vesktop;
in
{
  options.custom.apps.vesktop = {
    enable = mkEnableOption "Custom Discord client";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.vesktop ];

    custom.system.persistence.userConfig = {
      directories = [ ".config/vesktop/sessionData" ];
    };

    custom.system.home = {
      # disable the initial setup prompt
      configFile = {
        "vesktop/state.json" = {
          text = builtins.toJSON {
            firstLaunch = false;
          };
        };
      };
      extraOptions = {
        programs.vesktop = {
          enable = true;
          settings = {
            appBadge = false;
            arRPC = false;
            checkUpdates = false;
            customTitleBar = false;
            disableMinSize = false;
            minimizeToTray = true;
            tray = true;
            splashBackground = "#000000";
            splashColor = "#ffffff";
            splashTheming = false;
            staticTitle = true;
            hardwareAcceleration = true;
            discordBranch = "stable";
          };
        };
      };
    };
  };
}
