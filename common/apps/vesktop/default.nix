{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.vesktop;

  mkPlugin = attrs: { enabled = true; } // attrs;
in
{
  options.custom.apps.vesktop = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.vesktop ];

    custom.system.persistence.userConfig = {
      directories = [ ".config/vesktop" ];
    };

    custom.system.home = {
      configFiles = {
        # disable the initial setup prompt
        "vesktop/state.json" = {
          text = builtins.toJSON {
            firstLaunch = false;
          };
        };
        "vesktop/settings/settings.json".force = true;
      };
      extraOptions = {
        programs.vesktop = {
          enable = true;
          settings = {
            appBadge = false;
            staticTitle = true;
          };
          vencord.settings = {
            plugins = {
              MessageLogger = mkPlugin { };
              VolumeBooster = mkPlugin { };
              SilentTyping = mkPlugin { };
              NoPendingCount = mkPlugin { };
              ViewRaw = mkPlugin { };
            };
          };
        };
      };
    };
  };
}
