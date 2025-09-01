{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.hardware.wheel;
in
{
  options.custom.hardware.wheel = {
    enable = mkEnableOption "Logitech steering wheel support";
  };

  config = mkIf cfg.enable {
    hardware.usb-modeswitch.enable = true;
    services.udev.packages = [ pkgs.oversteer ];
    environment.systemPackages = [ pkgs.logiops ];
  };
}
