{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.jellyseerr;
in
{
  options.custom.services.jellyseerr = {
    enable = custom.enableOption;

    subdomain = mkOption {
      type = types.str;
      default = "search.media";
    };

    port = mkOption {
      type = types.port;
      default = 5055;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      { assertion = config.custom.system.media.enable; }
      { assertion = config.custom.services.jellyfin.enable; }
      { assertion = config.custom.services.arr.enable; }
    ];

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

    systemd = {
      services = {
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

      tmpfiles.settings."10-jellyseerr-settings"."/var/lib/jellyseerr/config/settings.json"."C" = {
        argument = config.sops.templates.jellyseerr-config.path;
        user = "jellyseerr";
        group = "media";
        mode = "0700";
      };
    };

    sops = {
      templates.jellyseerr-config = {
        content = import ./config.nix {
          inherit lib config;
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

    custom = {
      services.caddy.hosts = {
        jellyseerr.target = ":${toString cfg.port}";
      };

      system.persistence.config = {
        directories = [
          {
            directory = "/var/lib/jellyseerr";
            user = "jellyseerr";
            group = "media";
            mode = "0700";
          }
        ];
      };
    };
  };
}
