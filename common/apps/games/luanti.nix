{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.luanti;
in
{
  options.custom.apps.luanti = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.luanti
    ];

    custom.system.persistence.userConfig = {
      directories = [ ".minetest" ];
    };
  };
}
