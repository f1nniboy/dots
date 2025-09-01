{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.boot;
in
{
  options.custom.system.boot = {
    enable = mkEnableOption "boot configuration";
  };

  config = mkIf cfg.enable {
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 5;
        };
        efi.canTouchEfiVariables = true;
        timeout = 10;
      };
    };
  };
}
