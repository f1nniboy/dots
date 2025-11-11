{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.karakeep;
  serviceDomain = custom.mkServiceDomain config "karakeep";
in
{
  options.custom.services.karakeep = {
    enable = custom.enableOption;

    subdomain = mkOption {
      type = types.str;
      default = "keep";
    };

    port = mkOption {
      type = types.port;
      default = 3001;
    };
  };

  config = mkIf cfg.enable {
    systemd.services = {
      karakeep = {
        path = [
          pkgs.yt-dlp # video downloading
        ];
      };
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
        PORT = toString cfg.port;

        NEXTAUTH_URL = "https://${serviceDomain}";
        NEXTAUTH_URL_INTERNAL = "http://localhost:${toString cfg.port}";

        OAUTH_WELLKNOWN_URL = "https://${custom.mkServiceDomain config "authelia"}/.well-known/openid-configuration";
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
        content =
          let
            mkSecret = path: custom.mkSecretPlaceholder config "karakeep/${path}" "karakeep";
          in
          ''
            OAUTH_CLIENT_ID="${custom.mkSecretPlaceholder config "oidc/karakeep/id" "karakeep"}"
            OAUTH_CLIENT_SECRET="${custom.mkSecretPlaceholder config "oidc/karakeep/secret" "karakeep"}"

            OPENAI_API_KEY="${mkSecret "openai-api-key"}"
          '';
        owner = "karakeep";
      };
    };

    custom = {
      services = {
        caddy.hosts = {
          karakeep.target = ":${toString cfg.port}";
        };
        authelia = {
          rules = [
            # required to use the mobile app & browser extension
            {
              domain = serviceDomain;
              policy = "bypass";
              resources = [ "/api.*" ];
            }
          ];
          clients = [
            {
              name = "Karakeep";
              redirectUris = [
                "https://${serviceDomain}/api/auth/callback/custom"
              ];
            }
          ];
        };
        restic.paths = [ "/var/lib/karakeep" ];
      };

      system = {
        sops.secrets = [
          {
            path = "karakeep/openai-api-key";
            owner = "karakeep";
          }
        ];
        persistence.config = {
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
  };
}
