{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.hardware.fingerprint;
in
{
  options.custom.hardware.fingerprint = {
    enable = mkEnableOption "Fingerprint reader support";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.fprintd ];
    services.fprintd = {
      enable = true;
    };
  };
}
