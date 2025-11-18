{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.jellyseerr;

  configContent = builtins.toJSON (
    import ./config.nix {
      inherit lib config;
    }
  );
in
{
  options.custom.services.jellyseerr = {
    enable = custom.enableOption;

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
        content = configContent;
      };
    };

    custom = {
      system = {
        sops.secrets = [
          {
            path = "jellyseerr/api-key";
            owner = "jellyseerr";
          }
          {
            path = "jellyseerr/client-id";
            owner = "jellyseerr";
          }
          {
            path = "jellyseerr/vapid/public";
            owner = "jellyseerr";
          }
          {
            path = "jellyseerr/vapid/private";
            owner = "jellyseerr";
          }

          # api keys
          {
            path = "jellyfin/api-keys/jellyseerr";
            owner = "jellyseerr";
          }
          {
            path = "radarr/api-key";
            owner = "jellyseerr";
          }
          {
            path = "sonarr/api-key";
            owner = "jellyseerr";
          }
        ];
        persistence.config = {
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
      services.caddy.hosts = {
        jellyseerr.target = ":${toString cfg.port}";
      };
    };
  };
}
