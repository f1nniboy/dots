{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.easyeffects;
in
{
  options.custom.apps.easyeffects = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.easyeffects ];

    custom.system.persistence.userConfig = {
      directories = [ ".config/easyeffects" ];
    };
  };
}
