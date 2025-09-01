{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.chromium;
in
{
  options.custom.apps.chromium = {
    enable = mkEnableOption "Chromium web browser";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.chromium ];

    custom.system.persistence.userConfig = {
      directories = [ ".config/chromium" ];
    };
  };
}
