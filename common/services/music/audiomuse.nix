{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.audiomuse;

  ports = {
    postgres = 35432;
    redis = 36379;
  };

  commonServiceConfig = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    partOf = [ "docker-compose-audiomuse-root.target" ];
    wantedBy = [ "docker-compose-audiomuse-root.target" ];
  };

  env = {
    "JELLYFIN_TOKEN" = "f4cfb4350c70404e96d3bf47c51bd01c";
    "JELLYFIN_URL" = "https://media.f1nn.space";
    "JELLYFIN_USER_ID" = "08bbef95d1e949fcb9c52b1ce0e533aa";
    "MEDIASERVER_TYPE" = "jellyfin";
    "POSTGRES_DB" = "audiomusedb";
    "POSTGRES_HOST" = "127.0.0.1";
    "POSTGRES_PASSWORD" = "audiomusepassword";
    "POSTGRES_PORT" = toString ports.postgres;
    "POSTGRES_USER" = "audiomuse";
    "REDIS_URL" = "redis://127.0.0.1:${toString ports.redis}/0";
  };

  port = 8000;
in
{
  options.custom.services.audiomuse = {
    enable = mkEnableOption "Sonic analysis and AI-powered clustering to create smart, tempo and mood-based playlists within Jellyfin and Navidrome";
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      "audiomuse-flask" = {
        image = "ghcr.io/neptunehub/audiomuse-ai:devel";
        environment = mkMerge [
          env
          {
            "SERVICE_TYPE" = "flask";
          }
        ];
        volumes = [
          "/var/lib/audiomuse/app:/app/temp_audio:rw"
        ];
        dependsOn = [
          "audiomuse-postgres"
          "audiomuse-redis"
        ];
        extraOptions = [
          "--network=host"
        ];  
      };
      "audiomuse-postgres" = {
        image = "postgres:15-alpine";
        environment = {
          "POSTGRES_DB" = env.POSTGRES_DB;
          "POSTGRES_PASSWORD" = env.POSTGRES_PASSWORD;
          "POSTGRES_USER" = env.POSTGRES_USER;
        };
        ports = [
          "${toString ports.postgres}:5432"
        ];
        volumes = [
          "/var/lib/audiomuse/postgres:/var/lib/postgresql/data:rw"
        ];
      };
      "audiomuse-redis" = {
        image = "redis:7-alpine";
        ports = [
          "${toString ports.redis}:6379"
        ];
        volumes = [
          "/var/lib/audiomuse/redis:/data:rw"
        ];
      };
    };

    systemd.services = {
      "docker-audiomuse-flask" = commonServiceConfig;
      "docker-audiomuse-postgres" = commonServiceConfig;
      "docker-audiomuse-redis" = commonServiceConfig;
    };

    # root service
    systemd.targets."docker-compose-audiomuse-root" = {
      wantedBy = [ "multi-user.target" ];
    };

    custom.services.caddy.hosts = {
      audiomuse = {
        subdomain = "ai.${config.custom.services.caddy.hosts.jellyfin.subdomain}";
        target = ":${toString port}";
        import = [ "auth" ];
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/audiomuse";
          mode = "0700";
        }
      ];
    };
  };
}
