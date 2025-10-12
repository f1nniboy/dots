{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.notesnook;
in
{
  options.custom.apps.notesnook = {
    enable = mkEnableOption "Encrypted note-taking app";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.notesnook ];

    custom.system = {
      persistence.userConfig = {
        directories = [ ".config/Notesnook" ];
      };
      home = {
        # TODO: figure out how to declaratively configure api urls
        configFiles = {
          "Notesnook/config.json" = {
            text = builtins.toJSON {
              theme = "system";
              windowControlsIconColor = "#808080";
              backgroundColor = "#181818";
              desktopSettings = {
                autoStart = false;
                startMinimized = false;
                minimizeToTray = false;
                closeToSystemTray = false;
                nativeTitlebar = false;
              };
            };
          };
        };
      };
    };
  };
}
