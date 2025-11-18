{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.xonotic;
in
{
  options.custom.apps.xonotic = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.xonotic ];

    custom.system.persistence.userConfig = {
      directories = [ ".xonotic" ];
    };
  };
}
