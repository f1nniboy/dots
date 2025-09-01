{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.gimp;
in
{
  options.custom.apps.gimp = {
    enable = mkEnableOption "GNU Image Manipulation Program";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.gimp ];
  };
}
