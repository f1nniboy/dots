{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.soju;
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
      hostName = "irc.f1nn.space";
      listen = [
        "ircs://:6697"
      ];
      tlsCertificate = "/var/lib/acme/irc.f1nn.space/fullchain.pem";
      tlsCertificateKey = "/var/lib/acme/irc.f1nn.space/key.pem";
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
