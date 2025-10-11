{
  config,
  lib,
  pkgs,
  ...
}:
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
      kernelPackages = pkgs.linuxPackages_latest;
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 5;
        };
        efi.canTouchEfiVariables = true;
        timeout = 10;
      };
      tmp = {
        cleanOnBoot = true;
      };
    };
  };
}
