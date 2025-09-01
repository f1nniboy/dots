{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.thunderbird;
in
{
  options.custom.apps.thunderbird = {
    enable = mkEnableOption "Thunderbird e-mail client";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.thunderbird ];
  };
}
