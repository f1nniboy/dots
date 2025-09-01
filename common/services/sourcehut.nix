{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.sourcehut;
in
{
  options.custom.services.sourcehut = {
    enable = mkEnableOption "SourceHut git forge";
  };

  config = mkIf cfg.enable {
    services.sourcehut = {
      enable = true;
      git.enable = true;
      meta.enable = true;
      settings = {
        "sr.ht" = {
          environment = "production";
          global-domain = fqdn;
          origin = "https://${fqdn}";
          # Produce keys with srht-keygen from sourcehut.coresrht.
          network-key = "/run/keys/path/to/network-key";
          service-key = "/run/keys/path/to/service-key";
        };
        webhooks.private-key = "/run/keys/path/to/webhook-key";
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/git";
          user = "cgit";
          group = "cgit";
          mode = "0700";
        }
      ];
    };
  };
}
