{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.swap;
in
{
  options.custom.system.swap = {
    enable = mkEnableOption "Memory swapping";
  };

  config = mkIf cfg.enable {
    zramSwap.enable = true;

    swapDevices = [{
      device = "/var/lib/swapfile";
      size = 16 * 1024; # 16 GB
    }];

    environment.persistence."/nix/persist" = {
      files = [ "/var/lib/swapfile" ];
    };
  };
}
