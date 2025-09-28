{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.sabnzbd;
in
{
  options.custom.services.sabnzbd = {
    enable = mkEnableOption "SABnzbd download client";

      port = mkOption {
      type = types.port;
      default = 8080;
    };
  };

  config = mkIf cfg.enable {
    services.sabnzbd = {
      enable = true;
      group = "media";
    };

    custom.services.caddy.hosts = {
      sabnzbd = {
        subdomain = "dl.media";
        target = ":${toString cfg.port}";
        import = [ "auth" ];
      };
    };

    systemd = {
      tmpfiles.settings."10-sabnzbd-config"."/var/lib/sabnzbd/sabnzbd.ini"."C+" = {
        user = "sabnzbd";
        group = "media";
        mode = "0700";
        argument = config.sops.templates.sabnzbd-config.path;
      };
    };

    sops = {
      templates.sabnzbd-config = {
        content = import ../config/sabnzbd.nix {
          inherit cfg config;
        };
        owner = "sabnzbd";
      };
      secrets = {
        "${config.networking.hostName}/sabnzbd/api-key".owner = "sabnzbd";
        "${config.networking.hostName}/sabnzbd/nzb-key".owner = "sabnzbd";
        "${config.networking.hostName}/sabnzbd/server/username".owner = "sabnzbd";
        "${config.networking.hostName}/sabnzbd/server/password".owner = "sabnzbd";

      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/sabnzbd";
          user = "sabnzbd";
          group = "media";
          mode = "0700";
        }
      ];
    };

    custom.services.restic.paths = [
      "/var/lib/sabnzbd"
    ];
  };
}
