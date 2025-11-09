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
        (mkIf (!cfg.legacy) {
          systemd-boot = {
            enable = true;
            configurationLimit = 5;
          };
        })
        (mkIf cfg.legacy {
          grub = {
            enable = true;
            device = "/dev/sda";
          };
        })
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
