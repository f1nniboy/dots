{ config, lib, ... }:
with lib;
let
  cfg = config.custom.hardware.bluetooth;
in
{
  options.custom.hardware.bluetooth = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    custom.system.persistence.config = {
      directories = [ "/var/lib/bluetooth" ];
    };
  };
}
