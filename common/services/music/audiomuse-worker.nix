{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.audiomuse-worker;

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
    "POSTGRES_HOST" = cfg.host;
    "POSTGRES_PASSWORD" = "audiomusepassword";
    "POSTGRES_PORT" = toString ports.postgres;
    "POSTGRES_USER" = "audiomuse";
    "REDIS_URL" = "redis://${cfg.host}:${toString ports.redis}/0";
  };
in
{
  options.custom.services.audiomuse-worker = {
    enable = mkEnableOption "Worker for AudioMuse AI";

    host = mkOption {
      type = types.str;
      default = "100.100.10.10";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      "audiomuse-worker-1" = {
        image = "ghcr.io/neptunehub/audiomuse-ai:devel";
        environment = mkMerge [
          env
          {
            "SERVICE_TYPE" = "worker";
          }
        ];
        volumes = [
          "/var/lib/audiomuse-worker:/app/temp_audio:rw"
        ];
        extraOptions = [
          "--network=host"
        ];
      };
      "audiomuse-worker-2" = {
        image = "ghcr.io/neptunehub/audiomuse-ai:devel";
        environment = mkMerge [
          env
          {
            "SERVICE_TYPE" = "worker";
          }
        ];
        volumes = [
          "/var/lib/audiomuse-worker:/app/temp_audio:rw"
        ];
        extraOptions = [
          "--network=host"
        ];
      };
      "audiomuse-worker-3" = {
        image = "ghcr.io/neptunehub/audiomuse-ai:devel";
        environment = mkMerge [
          env
          {
            "SERVICE_TYPE" = "worker";
          }
        ];
        volumes = [
          "/var/lib/audiomuse-worker:/app/temp_audio:rw"
        ];
        extraOptions = [
          "--network=host"
        ];
      };
      "audiomuse-worker-4" = {
        image = "ghcr.io/neptunehub/audiomuse-ai:devel";
        environment = mkMerge [
          env
          {
            "SERVICE_TYPE" = "worker";
          }
        ];
        volumes = [
          "/var/lib/audiomuse-worker:/app/temp_audio:rw"
        ];
        extraOptions = [
          "--network=host"
        ];
      };
    };

    systemd.services = {
      "docker-audiomuse-worker-1" = commonServiceConfig;
      "docker-audiomuse-worker-2" = commonServiceConfig;
      "docker-audiomuse-worker-3" = commonServiceConfig;
      "docker-audiomuse-worker-4" = commonServiceConfig;
    };

    # root service
    systemd.targets."docker-compose-audiomuse-root" = {
      wantedBy = [ "multi-user.target" ];
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/audiomuse-worker";
          mode = "0700";
        }
      ];
    };
  };
}
