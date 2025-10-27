{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.samba;
in
{
  options.custom.services.samba = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    # TODO: figure out how to set password for samba accounts declaratively
    services.samba = {
      enable = true;
      openFirewall = true;
    };

    custom.system.persistence.config = {
      directories = [
        {
          directory = "/var/lib/samba";
          mode = "0700";
        }
      ];
    };
  };
}
