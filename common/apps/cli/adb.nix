{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.adb;
in
{
  options.custom.apps.adb = {
    enable = mkEnableOption "android debugging";
  };

  config = mkIf cfg.enable {
    services.udev.packages = [
      pkgs.android-udev-rules
    ];

    custom.system.user.extraGroups = [
      "adbusers"
    ];

    programs.adb.enable = true;
  };
}
