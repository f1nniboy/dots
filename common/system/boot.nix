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
    enable = custom.enableOption;
    legacy = custom.enableOption;
  };

  config = mkIf cfg.enable {
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      loader = mkMerge [
        (
          if cfg.legacy then
            {
              grub = {
                enable = true;
                device = "/dev/sda";
              };
            }
          else
            {
              systemd-boot = {
                enable = true;
                configurationLimit = 5;
              };
            }
        )
        {
          efi.canTouchEfiVariables = true;
          timeout = 10;
        }
      ];
      tmp = {
        cleanOnBoot = true;
      };
    };
  };
}
