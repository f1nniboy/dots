{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.printing;
in
{
  options.custom.services.printing = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    services = {
      printing.enable = true;
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
  };
}
