{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.arr;
in
{

  options.custom.services.arr = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    users = {
      users.prowlarr = {
        isSystemUser = true;
        group = "media";
      };
    };

    services = {
      prowlarr = {
        enable = true;
      };
      radarr = {
        enable = true;
        group = "media";
      };
      sonarr = {
        enable = true;
        group = "media";
      };
      recyclarr = {
        enable = true;
        group = "media";
        configuration = import ../config/recyclarr.nix {
          inherit config;
        };
      };
    };

    systemd.services = {
      prowlarr = {
        serviceConfig = {
          DynamicUser = mkForce false;
          User = "prowlarr";
          Group = "media";
        };
        environment = {
          PROWLARR__AUTH__REQUIRED = "True";
          PROWLARR__AUTH__METHOD = "External";
        };
      };
      radarr = {
        environment = {
          RADARR__AUTH__REQUIRED = "True";
          RADARR__AUTH__METHOD = "External";
        };
      };
      sonarr = {
        environment = {
          SONARR__AUTH__REQUIRED = "True";
          SONARR__AUTH__METHOD = "External";
        };
      };
      recyclarr.serviceConfig.LoadCredential = [
        "radarr_api-key:${
          config.sops.secrets."recyclarr-${config.networking.hostName}/radarr/api-key".path
        }"
        "sonarr_api-key:${
          config.sops.secrets."recyclarr-${config.networking.hostName}/sonarr/api-key".path
        }"
      ];
    };

    custom = {
      services = {
        caddy.hosts = {
          prowlarr = {
            subdomain = "idx.media";
            target = ":${toString config.services.prowlarr.settings.server.port}";
            import = [ "auth" ];
          };
          radarr = {
            subdomain = "mov.media";
            target = ":${toString config.services.radarr.settings.server.port}";
            import = [ "auth" ];
          };
          sonarr = {
            subdomain = "tv.media";
            target = ":${toString config.services.sonarr.settings.server.port}";
            import = [ "auth" ];
          };
        };
        authelia.rules = [
          # required for nzb360 mobile app
          {
            domain = "*.media.${config.custom.services.caddy.domain}";
            policy = "bypass";
            resources = [ "/api.*" ];
          }
        ];
      };

      system.persistence.config = {
        directories = [
          {
            directory = "/var/lib/prowlarr";
            user = "prowlarr";
            group = "media";
            mode = "0700";
          }
          {
            directory = "/var/lib/radarr";
            user = "radarr";
            group = "media";
            mode = "0700";
          }
          {
            directory = "/var/lib/sonarr";
            user = "sonarr";
            group = "media";
            mode = "0700";
          }
        ];
      };

      services.restic = {
        paths = [
          "/var/lib/prowlarr"
          "/var/lib/radarr"
          "/var/lib/sonarr"
        ];
        exclude = [
          "/var/lib/prowlarr/Definitions"
          "/var/lib/prowlarr/Backups"
          "/var/lib/prowlarr/logs"

          "/var/lib/sonarr/.config/NzbDrone/MediaCover"
          "/var/lib/sonarr/.config/NzbDrone/Backups"
          "/var/lib/sonarr/.config/NzbDrone/logs"

          "/var/lib/radarr/.config/Radarr/MediaCover"
          "/var/lib/radarr/.config/Radarr/Backups"
          "/var/lib/radarr/.config/Radarr/logs"
        ];
      };
    };

    sops.secrets = {
      "recyclarr-${config.networking.hostName}/radarr/api-key" = {
        key = "${config.networking.hostName}/radarr/api-key";
        owner = "recyclarr";
      };
      "recyclarr-${config.networking.hostName}/sonarr/api-key" = {
        key = "${config.networking.hostName}/sonarr/api-key";
        owner = "authelia-main";
      };
    };
  };
}
