{
  config,
  lib,
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
    services.fprintd = {
      enable = true;
    };

    custom.system.persistence.config = {
      directories = [ "/var/lib/fprint" ];
    };
  };
}
