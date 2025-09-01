{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.samba;
in
{
  options.custom.services.samba = {
    enable = mkEnableOption "Samba file-sharing server";
  };

  config = mkIf cfg.enable {
    # TODO: figure out how to set password for samba accounts in config here
    services.samba = {
      enable = true;
      openFirewall = true;
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/samba";
          mode = "0700";
        }
      ];
    };
  };
}
