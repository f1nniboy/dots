{ config, lib, ... }:
with lib;
let
  cfg = config.custom.hardware.bluetooth;
in
{
  options.custom.hardware.bluetooth = {
    enable = mkEnableOption "bluetooth support";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    environment.persistence."/nix/persist" = {
      directories = [ "/var/lib/bluetooth" ];
    };
  };
}
