{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.supertux;
in
{
  options.custom.apps.supertux = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.superTux
    ];

    custom.system.persistence.userConfig = {
      directories = [ ".local/share/supertux2" ];
    };
  };
}
