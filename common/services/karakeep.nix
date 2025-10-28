{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.karakeep;
in
{
  options.custom.services.karakeep = {
    enable = custom.enableOption;

    port = mkOption {
      type = types.port;
      default = 3001;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      yt-dlp # video downloading
    ];

    systemd.services = {
      karakeep-browser = {
        serviceConfig = {
          DynamicUser = mkForce false;
          User = "karakeep";
          Group = "karakeep";
        };
      };
    };

    services.karakeep = {
      enable = true;
      meilisearch.enable = false;
      extraEnvironment = {
        DISABLE_NEW_RELEASE_CHECK = "true";
        NEXTAUTH_URL = "https://keep.${config.custom.services.caddy.domain}";
        PORT = toString cfg.port;

        NEXTAUTH_URL_INTERNAL = "http://localhost:${toString cfg.port}";

        OAUTH_WELLKNOWN_URL = "https://auth.${config.custom.services.caddy.domain}/.well-known/openid-configuration";
        OAUTH_ALLOW_DANGEROUS_EMAIL_ACCOUNT_LINKING = "true";
        OAUTH_PROVIDER_NAME = "Authelia";

        CRAWLER_FULL_PAGE_SCREENSHOT = "true";
        CRAWLER_SCREENSHOT_TIMEOUT_SEC = "10";

        CRAWLER_VIDEO_DOWNLOAD = "true";
        CRAWLER_VIDEO_DOWNLOAD_MAX_SIZE = "-1";
      };
      environmentFile = config.sops.templates.karakeep-secrets.path;
    };

    sops = {
      templates."karakeep-secrets" = {
        content = ''
          OAUTH_CLIENT_ID="${config.sops.placeholder."${config.networking.hostName}/oidc/karakeep/id"}"
          OAUTH_CLIENT_SECRET="${
            config.sops.placeholder."${config.networking.hostName}/oidc/karakeep/secret"
          }"

          OPENAI_API_KEY="${config.sops.placeholder."${config.networking.hostName}/karakeep/openai-api-key"}"
        '';
        owner = "karakeep";
      };
      secrets = {
        "${config.networking.hostName}/karakeep/openai-api-key".owner = "karakeep";

        "${config.networking.hostName}/oidc/karakeep/secret".owner = "karakeep";
        "${config.networking.hostName}/oidc/karakeep/secret-hash".owner = "authelia-main";
        "${config.networking.hostName}/oidc/karakeep/id".owner = "karakeep";
        "authelia-${config.networking.hostName}/oidc/karakeep/id" = {
          key = "${config.networking.hostName}/oidc/karakeep/id";
          owner = "authelia-main";
        };
      };
    };

    custom = {
      services = {
        caddy.hosts = {
          karakeep = {
            subdomain = "keep";
            target = ":${toString cfg.port}";
          };
        };
        authelia.rules = [
          # required to use the mobile app & browser extension
          {
            domain = "keep.${config.custom.services.caddy.domain}";
            policy = "bypass";
            resources = [ "/api.*" ];
          }
        ];

        restic.paths = [
          "/var/lib/karakeep"
        ];
      };

      system.persistence.config = {
        directories = [
          {
            directory = "/var/lib/karakeep";
            user = "karakeep";
            group = "karakeep";
            mode = "0700";
          }
          {
            directory = "/var/lib/karakeep-browser";
            user = "karakeep";
            group = "karakeep";
            mode = "0700";
          }
        ];
      };
    };
  };
}
