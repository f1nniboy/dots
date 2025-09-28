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
    enable = mkEnableOption "An open source voxel game engine";
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
