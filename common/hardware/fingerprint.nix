{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.hardware.fingerprint;
in
{
  options.custom.hardware.fingerprint = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.fprintd ];

    services.fprintd = {
      enable = true;
    };

    custom.system.persistence.config = {
      directories = [ "/var/lib/fprint" ];
    };
  };
}
