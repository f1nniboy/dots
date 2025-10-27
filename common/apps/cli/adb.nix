{ config, lib, ... }:
with lib;
let
  cfg = config.custom.apps.adb;
in
{
  options.custom.apps.adb = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    custom.system.user.extraGroups = [
      "adbusers"
    ];

    programs.adb.enable = true;
  };
}
