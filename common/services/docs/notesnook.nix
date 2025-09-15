{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.notesnook;

  env = {
    "API_HOST" = "http://api:5264/";
    "ATTACHMENTS_SERVER_PUBLIC_URL" = "https://files.note.${config.custom.services.caddy.domain}";
    "AUTH_SERVER_PUBLIC_URL" = "https://auth.note.${config.custom.services.caddy.domain}";
    "DISABLE_ACCOUNT_CREATION" = "1";
    "DISABLE_SIGNUPS" = "1";
    "IDENTITY_SERVER_HOST" = "auth";
    "IDENTITY_SERVER_PORT" = "8264";
    "IDENTITY_SERVER_URL" = "https://auth.note.${config.custom.services.caddy.domain}";
    "INSTANCE_NAME" = "${config.networking.hostName}";
    "MINIO_ROOT_USER" = "admin";
    "MONOGRAPH_PUBLIC_URL" = "https://mono.note.${config.custom.services.caddy.domain}";
    "NOTESNOOK_APP_HOST" = "https://api.note.${config.custom.services.caddy.domain}";
    "NOTESNOOK_APP_PUBLIC_URL" = "https://api.note.${config.custom.services.caddy.domain}";
    "NOTESNOOK_SERVER_HOST" = "api";
    "NOTESNOOK_SERVER_PORT" = "5264";
    "SELF_HOSTED" = "1";
    "SSE_SERVER_HOST" = "sse";
    "SSE_SERVER_PORT" = "7264";
    "TZ" = config.time.timeZone;
    "MONGODB_CONNECTION_STRING" = "mongodb://db:27017/?replSet=rs0";

    # TODO: figure out how to pass these secrets as files
    "MINIO_ROOT_PASSWORD" = "n2QkzrlneGwi2eIj19w9itoXA4zDNThDlsXM994";
    "NOTESNOOK_API_SECRET" = "uMjStaTahmHHZENDKd5TCKISIBkPZtM9w5BOkyE";
    "S3_ACCESS_KEY" = "n2QkzrlneGwi2eIj19w9itoXA4zDNThDlsXM994";
  };

  commonServiceConfig = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [ "docker-network-notesnook.service" ];
    requires = [ "docker-network-notesnook.service" ];
    partOf = [ "docker-compose-notesnook-root.target" ];
    wantedBy = [ "docker-compose-notesnook-root.target" ];
  };
in
{
  options.custom.services.notesnook = {
    enable = mkEnableOption "Notesnook note-taking service";

    ports = mkOption {
      type = lib.types.submodule {
        options = {
          api = lib.mkOption {
            type = lib.types.port;
            default = 5001;
          };
          auth = lib.mkOption {
            type = lib.types.port;
            default = 5002;
          };
          mono = lib.mkOption {
            type = lib.types.port;
            default = 5003;
          };
          sse = lib.mkOption {
            type = lib.types.port;
            default = 5004;
          };
          s3 = lib.mkOption {
            type = lib.types.port;
            default = 5005;
          };
        };
      };
      default = { };
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.notesnook = {
        isSystemUser = true;
        group = "notesnook";
        uid = 1101;
      };
      groups.notesnook = {
        gid = 1101;
      };
    };

    custom.services = {
      caddy.hosts = {
        notesnook-api = {
          subdomain = "api.note";
          target = ":${toString cfg.ports.api}";
        };
        notesnook-auth = {
          subdomain = "auth.note";
          target = ":${toString cfg.ports.auth}";
        };
        notesnook-mono = {
          subdomain = "mono.note";
          target = ":${toString cfg.ports.mono}";
        };
        notesnook-sse = {
          subdomain = "sse.note";
          target = ":${toString cfg.ports.sse}";
        };
        notesnook-s3 = {
          subdomain = "files.note";
          target = ":${toString cfg.ports.s3}";
        };
      };
    };

    # containers
    virtualisation.oci-containers.containers = {
      "notesnook-api" = {
        image = "streetwriters/notesnook-sync:latest";
        ports = [ "127.0.0.1:${toString cfg.ports.api}:5264" ];
        environment = lib.mkMerge [
          env
          {
            "MONGODB_DATABASE_NAME" = "notesnook";
            "S3_ACCESS_KEY_ID" = "admin";
            "S3_BUCKET_NAME" = "attachments";
            "S3_INTERNAL_BUCKET_NAME" = "attachments";
            "S3_INTERNAL_SERVICE_URL" = "http://s3:9000/";
            "S3_REGION" = "us-east-1";
            "S3_SERVICE_URL" = "https://files.note.${config.custom.services.caddy.domain}";
          }
        ];
        dependsOn = [
          "notesnook-auth"
          "notesnook-s3"
          "notesnook-setup-s3"
        ];
        extraOptions = [
          "--network-alias=api"
          "--network=notesnook"
        ];
      };
      "notesnook-auth" = {
        image = "streetwriters/identity:latest";
        ports = [ "127.0.0.1:${toString cfg.ports.auth}:8264" ];
        environment = lib.mkMerge [
          env
          {
            "MONGODB_CONNECTION_STRING" = lib.mkForce "mongodb://db:27017/identity?replSet=rs0";
            "MONGODB_DATABASE_NAME" = "identity";
          }
        ];
        dependsOn = [
          "notesnook-db"
        ];
        extraOptions = [
          "--network-alias=auth"
          "--network=notesnook"
        ];
      };
      "notesnook-mono" = {
        image = "streetwriters/monograph:latest";
        ports = [ "127.0.0.1:${toString cfg.ports.mono}:3000" ];
        environment = lib.mkMerge [
          env
          {
            "PUBLIC_URL" = "https://mono.note.${config.custom.services.caddy.domain}";
          }
        ];
        dependsOn = [
          "notesnook-api"
        ];
        extraOptions = [
          "--network-alias=mono"
          "--network=notesnook"
        ];
      };
      "notesnook-sse" = {
        image = "streetwriters/sse:latest";
        ports = [ "127.0.0.1:${toString cfg.ports.sse}:7264" ];
        environment = env;
        dependsOn = [
          "notesnook-api"
          "notesnook-auth"
        ];
        extraOptions = [
          "--network-alias=sse"
          "--network=notesnook"
        ];
      };

      ### backend

      "notesnook-db" = {
        image = "mongo:latest";
        environment = env;
        volumes = [
          "/var/lib/notesnook/db:/data/configdb:rw"
          "/var/lib/notesnook/db:/data/db:rw"
        ];
        cmd = [
          "--replSet"
          "rs0"
          "--bind_ip_all"
        ];
        extraOptions = [
          "--hostname=notesnook-db"
          "--network-alias=db"
          "--network=notesnook"
        ];
      };
      "notesnook-s3" = {
        image = "minio/minio:latest";
        ports = [
          "127.0.0.1:${toString cfg.ports.s3}:9000"
          "9090:9090"
        ];
        environment = env;
        volumes = [
          "/var/lib/notesnook/s3:/data/s3:rw"
        ];
        cmd = [
          "server"
          "/data/s3"
          "--console-address"
          ":9090"
        ];
        extraOptions = [
          "--network-alias=s3"
          "--network=notesnook"
        ];
      };

      ### setup scripts

      "notesnook-initiate-rs0" = {
        image = "mongo:latest";
        environment = env;
        entrypoint = "/bin/sh";
        cmd = [
          "-c"
          "mongosh mongodb://db:27017 <<EOF
        rs.initiate();
        rs.status();
      EOF
      "
        ];
        dependsOn = [
          "notesnook-db"
        ];
        extraOptions = [
          "--network-alias=initiate-rs0"
          "--network=notesnook"
        ];
      };
      "notesnook-setup-s3" = {
        image = "minio/mc:latest";
        environment = env;
        entrypoint = "/bin/bash";
        cmd = [
          "-c"
          "until mc alias set minio http://s3:9000 admin n2QkzrlneGwi2eIj19w9itoXA4zDNThDlsXM994; do
        sleep 1;
      done;
      mc mb minio/attachments -p
      "
        ];
        dependsOn = [
          "notesnook-s3"
        ];
        extraOptions = [
          "--network-alias=setup-s3"
          "--network=notesnook"
        ];
      };
    };

    systemd = {
      services = {
        "docker-notesnook-api" = commonServiceConfig;
        "docker-notesnook-auth" = commonServiceConfig;
        "docker-notesnook-db" = commonServiceConfig;
        "docker-notesnook-mono" = commonServiceConfig;
        "docker-notesnook-s3" = commonServiceConfig;
        "docker-notesnook-sse" = commonServiceConfig;
        "docker-notesnook-initiate-rs0" = lib.mkMerge [
          commonServiceConfig
          {
            serviceConfig = {
              Restart = lib.mkOverride 10 "no";
            };
          }
        ];
        "docker-notesnook-setup-s3" = lib.mkMerge [
          commonServiceConfig
          {
            serviceConfig = {
              Restart = lib.mkOverride 10 "no";
            };
          }
        ];

        # network
        "docker-network-notesnook" = {
          path = [ pkgs.docker ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStop = "docker network rm -f notesnook";
          };
          script = ''
            docker network inspect notesnook || docker network create notesnook
          '';
          partOf = [ "docker-compose-notesnook-root.target" ];
          wantedBy = [ "docker-compose-notesnook-root.target" ];
        };
      };

      # root service
      targets."docker-compose-notesnook-root" = {
        wantedBy = [ "multi-user.target" ];
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/notesnook";
          mode = "0700";
        }
      ];
    };
  };
}
