{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.soju;
  domain = "irc.${config.custom.services.caddy.domain}";
in
{
  options.custom.services.soju = {
    enable = mkEnableOption "IRC bouncer";
  };

  config = mkIf cfg.enable {
    users = {
      users.soju = {
        isSystemUser = true;
        group = "soju";
      };
      groups.soju = { };
    };

    services.soju = {
      enable = true;
      hostName = domain;
      listen = [
        "ircs://:6697"
      ];
      tlsCertificate = "/var/lib/acme/${domain}/fullchain.pem";
      tlsCertificateKey = "/var/lib/acme/${domain}/key.pem";
    };

    systemd.services.soju = {
      serviceConfig = {
        DynamicUser = mkForce false;
        User = mkForce "soju";
        Group = mkForce "soju";
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/soju";
          user = "soju";
          group = "soju";
          mode = "0700";
        }
      ];
    };
  };
}
