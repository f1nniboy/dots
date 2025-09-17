{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.apps.supertux;
in
{
  options.custom.apps.supertux = {
    enable = mkEnableOption "Classic 2D jump'n run sidescroller game";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.superTux
    ];

    custom.system.persistence.userConfig = {
    #  directories = [ ".minetest" ];
    };
  };
}
