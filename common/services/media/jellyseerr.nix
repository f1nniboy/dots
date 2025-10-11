{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.jellyseerr;
in
{
  options.custom.services.jellyseerr = {
    enable = mkEnableOption "Jellyseerr media requester";

    port = mkOption {
      type = types.port;
      default = 5055;
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.jellyseerr = {
        isSystemUser = true;
        group = "media";
      };
    };

    services.jellyseerr = {
      enable = true;
      inherit (cfg) port;
    };

    systemd.services = {
      jellyseerr = {
        environment = {
          HOST = "127.0.0.1";
        };
        serviceConfig = {
          DynamicUser = mkForce false;
          User = "jellyseerr";
          Group = "media";
        };
      };
    };

    custom.services.caddy.hosts = {
      jellyseerr = {
        subdomain = "search.media";
        target = ":${toString cfg.port}";
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/jellyseerr";
          user = "jellyseerr";
          group = "media";
          mode = "0700";
        }
      ];
    };

    systemd.tmpfiles.settings."10-jellyseerr-settings"."/var/lib/jellyseerr/config/settings.json"."C" =
      {
        argument = config.sops.templates.jellyseerr-config.path;
        user = "jellyseerr";
        group = "media";
        mode = "0700";
      };

    sops = {
      templates.jellyseerr-config = {
        content = import ../config/jellyseerr.nix {
          inherit config;
        };
      };
      secrets = {
        "${config.networking.hostName}/jellyseerr/api-key".owner = "jellyseerr";
        "${config.networking.hostName}/jellyseerr/client-id".owner = "jellyseerr";
        "${config.networking.hostName}/jellyseerr/vapid/public".owner = "jellyseerr";
        "${config.networking.hostName}/jellyseerr/vapid/private".owner = "jellyseerr";

        "jellyseerr-${config.networking.hostName}/jellyfin/server-id" = {
          key = "${config.networking.hostName}/jellyfin/server-id";
          owner = "jellyseerr";
        };
        "jellyseerr-${config.networking.hostName}/jellyfin/api-keys/jellyseerr" = {
          key = "${config.networking.hostName}/jellyfin/api-keys/jellyseerr";
          owner = "jellyseerr";
        };
        "jellyseerr-${config.networking.hostName}/radarr/api-key" = {
          key = "${config.networking.hostName}/radarr/api-key";
          owner = "jellyseerr";
        };
        "jellyseerr-${config.networking.hostName}/sonarr/api-key" = {
          key = "${config.networking.hostName}/sonarr/api-key";
          owner = "jellyseerr";
        };
      };
    };
  };
}
