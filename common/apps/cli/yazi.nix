{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.yazi;
in
{
  options.custom.apps.yazi = {
    enable = mkEnableOption "Yazi file manager";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.yazi ];
  };
}
