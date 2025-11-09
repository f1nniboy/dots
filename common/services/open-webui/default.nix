{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.open-webui;
  serviceDomain = custom.mkServiceDomain config "open-webui";
in
{
  options.custom.services.open-webui = {
    enable = custom.enableOption;

    forOidc = mkOption {
      type = types.bool;
      default = cfg.enable;
    };

    subdomain = mkOption {
      type = types.str;
      default = "chat";
    };

    port = mkOption {
      type = types.port;
      default = 13024;
    };
  };

  config = mkMerge [
    (mkIf cfg.forOidc {
      custom.services.authelia.clients.open-webui = {
        name = "Open WebUI";
        id = "open-webui";
        redirectUris = [
          "https://${serviceDomain}/oauth/oidc/callback"
        ];
        requirePkce = true;
      };
    })
    (mkIf cfg.enable {
      users = {
        users.open-webui = {
          isSystemUser = true;
          group = "open-webui";
        };
        groups.open-webui = { };
      };

      systemd.services.open-webui = {
        serviceConfig = {
          DynamicUser = mkForce false;
          User = "open-webui";
          Group = "open-webui";
        };
      };

      services.open-webui = {
        enable = true;
        inherit (cfg) port;
        environment = {
          # TODO: "Failed to initialize the database connection: Postgres driver not installed!"
          # i will just use the sqlite db for now
          #DATABASE_URL = "postgresql://open-webui:@/open-webui";

          # general
          WEBUI_URL = "https://${serviceDomain}";

          # oauth
          ENABLE_OAUTH_PERSISTENT_CONFIG = "false";
          OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "true";
          ENABLE_OAUTH_SIGNUP = "true";
          OPENID_PROVIDER_URL = "https://${custom.mkServiceDomain config "authelia"}/.well-known/openid-configuration";
          OAUTH_PROVIDER_NAME = "Authelia";
          OAUTH_SCOPES = "openid email profile groups";
          ENABLE_OAUTH_ROLE_MANAGEMENT = "true";
          OAUTH_ALLOWED_ROLES = "srv:ai";
          OAUTH_ADMIN_ROLES = "role:admin";
          OAUTH_ROLES_CLAIM = "groups";
        };
        environmentFile = config.sops.templates.open-webui-secrets.path;
      };

      sops = {
        templates.open-webui-secrets = {
          content = ''
            OAUTH_CLIENT_ID=${custom.mkSecretPlaceholder config "oidc/open-webui/id" "open-webui"}
            OAUTH_CLIENT_SECRET=${custom.mkSecretPlaceholder config "oidc/open-webui/secret" "open-webui"}
          '';
          owner = "open-webui";
          mode = "0600";
        };
      };

      custom = {
        system = {
          packages.unfreePackages = [
            "open-webui"
          ];
          persistence.config = {
            directories = [
              {
                directory = "/var/lib/open-webui";
                user = "open-webui";
                group = "open-webui";
                mode = "0700";
              }
            ];
          };
        };
        services = {
          caddy.hosts = {
            open-webui.target = ":${toString cfg.port}";
          };
          authelia.clients.open-webui.makeSecrets = true;
          #postgresql.users = [ "open-webui" ];
        };
      };
    })
  ];
}
