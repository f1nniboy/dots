{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.apps.supertuxkart;
in
{
  options.custom.apps.supertuxkart = {
    enable = mkEnableOption "Classic 2D jump'n run sidescroller game";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.superTuxKart
    ];

    custom.system.persistence.userConfig = {
      directories = [
        ".local/share/supertuxkart"
        ".config/supertuxkart"
      ];
    };
  };
}
