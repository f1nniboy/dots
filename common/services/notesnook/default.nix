{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.notesnook;
  subdomain = custom.mkServiceSub config "notesnook";

  mkNotesnookDomain = sub: "https://${sub}.${custom.mkServiceDomain config "notesnook"}";

  mkPortOption =
    default:
    mkOption {
      type = types.port;
      inherit default;
    };

  env = {
    common = {
      INSTANCE_NAME = "notesnook";
      DISABLE_SIGNUPS = "false";
      SELF_HOSTED = "1";

      NOTESNOOK_CORS_ORIGINS = "https://app.notesnook.com";

      AUTH_SERVER_PUBLIC_URL = mkNotesnookDomain "auth";
      NOTESNOOK_APP_PUBLIC_URL = mkNotesnookDomain "api";
      MONOGRAPH_PUBLIC_URL = mkNotesnookDomain "mono";
      ATTACHMENTS_SERVER_PUBLIC_URL = mkNotesnookDomain "files";

      IDENTITY_SERVER_URL = env.common.AUTH_SERVER_PUBLIC_URL;
      NOTESNOOK_APP_HOST = env.common.NOTESNOOK_APP_PUBLIC_URL;

      MINIO_ROOT_USER = "minioadmin";
      MINIO_ROOT_PASSWORD = "minioadmin";

      NOTESNOOK_SERVER_PORT = "5264";
      NOTESNOOK_SERVER_HOST = "notesnook-api";
      IDENTITY_SERVER_PORT = "8264";
      IDENTITY_SERVER_HOST = "notesnook-auth";
      SSE_SERVER_PORT = "7264";
      SSE_SERVER_HOST = "notesnook-sse";
    };

    auth = env.common // {
      MONGODB_CONNECTION_STRING = "mongodb://notesnook-db:27017/identity?replSet=rs0";
      MONGODB_DATABASE_NAME = "identity";
    };

    api = env.common // {
      MONGODB_CONNECTION_STRING = "mongodb://notesnook-db:27017/?replSet=rs0";
      MONGODB_DATABASE_NAME = "notesnook";
      S3_INTERNAL_SERVICE_URL = "http://notesnook-s3:9000";
      S3_INTERNAL_BUCKET_NAME = "attachments";
      S3_ACCESS_KEY_ID = env.common.MINIO_ROOT_USER;
      S3_ACCESS_KEY = env.common.MINIO_ROOT_PASSWORD;
      S3_SERVICE_URL = env.common.ATTACHMENTS_SERVER_PUBLIC_URL;
      S3_REGION = "us-east-1";
      S3_BUCKET_NAME = "attachments";
    };

    s3 = env.common // {
      MINIO_BROWSER = "on";
    };

    sse = env.common;

    mono = env.common // {
      API_HOST = "http://notesnook-api:5264";
      PUBLIC_URL = "${env.common.MONOGRAPH_PUBLIC_URL}";
    };
  };
in
{
  options.custom.services.notesnook = {
    enable = custom.enableOption;

    ports = mkOption {
      type = types.submodule {
        options = {
          api = mkPortOption 5001;
          auth = mkPortOption 5002;
          mono = mkPortOption 5003;
          sse = mkPortOption 5004;
          s3 = mkPortOption 5005;
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

    virtualisation.arion.projects."notesnook".settings = {
      project.name = "notesnook";

      networks = {
        notesnook.name = "notesnook";
      };

      services = {
        db.service = {
          container_name = "notesnook-db";
          image = custom.mkDockerImage config "mongo";
          networks = [ "notesnook" ];
          volumes = [ "/var/lib/notesnook/db:/data/db" ];
          command = "--replSet rs0 --bind_ip_all";
          healthcheck = {
            test = [
              "CMD-SHELL"
              "echo 'try { rs.status() } catch (err) { rs.initiate() }; db.runCommand(\"ping\").ok' | mongosh mongodb://localhost:27017 --quiet"
            ];
            interval = "40s";
            timeout = "30s";
            retries = 3;
            start_period = "60s";
          };
        };

        s3.service = {
          container_name = "notesnook-s3";
          image = custom.mkDockerImage config "minio/minio";
          ports = [ "${toString cfg.ports.s3}:9000" ];
          networks = [ "notesnook" ];
          volumes = [ "/var/lib/notesnook/s3:/data/s3" ];
          environment = env.s3;
          command = [
            "server"
            "/data/s3"
            "--console-address"
            ":9090"
          ];
          healthcheck = {
            test = [
              "CMD"
              "curl"
              "-f"
              "http://localhost:9000/minio/health/live"
            ];
            interval = "40s";
            timeout = "30s";
            retries = 3;
            start_period = "60s";
          };
        };

        setup-s3.service = {
          image = custom.mkDockerImage config "minio/mc";
          networks = [ "notesnook" ];
          depends_on = [ "s3" ];
          entrypoint = "/bin/bash";
          environment = env.common;
          command = [
            "-c"
            ''
              until mc alias set minio http://notesnook-s3:9000 ${env.common.MINIO_ROOT_USER} ${env.common.MINIO_ROOT_PASSWORD}; do
                sleep 1;
              done;
              mc mb minio/attachments -p
            ''
          ];
        };

        auth.service = {
          container_name = "notesnook-auth";
          image = custom.mkDockerImage config "streetwriters/identity";
          ports = [ "${toString cfg.ports.auth}:8264" ];
          networks = [ "notesnook" ];
          env_file = [ config.sops.templates.notesnook-secrets.path ];
          environment = env.auth;
          depends_on = [ "db" ];
          healthcheck = {
            test = [
              "CMD"
              "curl"
              "-f"
              "http://localhost:8264/health"
            ];
            interval = "40s";
            timeout = "30s";
            retries = 3;
            start_period = "60s";
          };
        };

        api.service = {
          container_name = "notesnook-api";
          image = custom.mkDockerImage config "streetwriters/notesnook-sync";
          ports = [ "${toString cfg.ports.api}:5264" ];
          networks = [ "notesnook" ];
          env_file = [ config.sops.templates.notesnook-secrets.path ];
          environment = env.api;
          depends_on = [
            "s3"
            "setup-s3"
            "auth"
          ];
          healthcheck = {
            test = [
              "CMD"
              "curl"
              "-f"
              "http://localhost:5264/health"
            ];
            interval = "40s";
            timeout = "30s";
            retries = 3;
            start_period = "60s";
          };
        };

        sse.service = {
          container_name = "notesnook-sse";
          image = custom.mkDockerImage config "streetwriters/sse";
          ports = [ "${toString cfg.ports.sse}:7264" ];
          networks = [ "notesnook" ];
          env_file = [ config.sops.templates.notesnook-secrets.path ];
          environment = env.sse;
          depends_on = [
            "auth"
            "api"
          ];
          healthcheck = {
            test = [
              "CMD"
              "curl"
              "-f"
              "http://localhost:7264/health"
            ];
            interval = "40s";
            timeout = "30s";
            retries = 3;
            start_period = "60s";
          };
        };

        mono.service = {
          container_name = "notesnook-mono";
          image = custom.mkDockerImage config "streetwriters/monograph";
          ports = [ "${toString cfg.ports.mono}:3000" ];
          networks = [ "notesnook" ];
          environment = env.mono;
          depends_on = [ "api" ];
          healthcheck = {
            test = [
              "CMD"
              "curl"
              "-f"
              "http://localhost:3000/api/health"
            ];
            interval = "40s";
            timeout = "30s";
            retries = 3;
            start_period = "60s";
          };
        };
      };
    };

    sops = {
      templates.notesnook-secrets = {
        content =
          let
            mkSecret = path: custom.mkSecretPlaceholder config "notesnook/${path}" "notesnook";
          in
          ''
            NOTESNOOK_API_SECRET=${mkSecret "api-secret"}
            S3_ACCESS_KEY=${mkSecret "s3-access-key"}
          '';
        owner = "notesnook";
      };
    };

    custom = {
      system = {
        sops.secrets = [
          {
            path = "notesnook/s3-access-key";
            owner = "notesnook";
          }
          {
            path = "notesnook/api-secret";
            owner = "notesnook";
          }
        ];
        persistence.config = {
          directories = [
            {
              directory = "/var/lib/notesnook";
              mode = "0700";
            }
          ];
        };
      };
      services = {
        caddy.hosts = {
          notesnook-api = {
            sub = "api.${subdomain}";
            target = ":${toString cfg.ports.api}";
          };
          notesnook-auth = {
            sub = "auth.${subdomain}";
            target = ":${toString cfg.ports.auth}";
          };
          notesnook-mono = {
            sub = "mono.${subdomain}";
            target = ":${toString cfg.ports.mono}";
          };
          notesnook-sse = {
            sub = "sse.${subdomain}";
            target = ":${toString cfg.ports.sse}";
          };
          notesnook-s3 = {
            sub = "files.${subdomain}";
            target = ":${toString cfg.ports.s3}";
          };
        };
      };
    };
  };
}
