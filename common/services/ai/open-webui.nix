{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.open-webui;
in
{
  options.custom.services.open-webui = {
    enable = mkEnableOption "Self-hosted AI platform";
    port = mkOption {
      type = types.port;
      default = 13024;
    };
  };

  config = mkIf cfg.enable {
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
        WEBUI_URL = "https://${config.custom.services.caddy.hosts.open-webui.subdomain}.${config.custom.services.caddy.domain}";

        # oauth
        ENABLE_OAUTH_PERSISTENT_CONFIG = "false";
        OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "true";
        ENABLE_OAUTH_SIGNUP = "true";
        OPENID_PROVIDER_URL = "https://auth.${config.custom.services.caddy.domain}/.well-known/openid-configuration";
        OAUTH_PROVIDER_NAME = "Authelia";
        OAUTH_SCOPES = "openid email profile groups";
        ENABLE_OAUTH_ROLE_MANAGEMENT = "true";
        OAUTH_ALLOWED_ROLES = "srv:ai";
        OAUTH_ADMIN_ROLES = "role:admin";
        OAUTH_ROLES_CLAIM = "groups";
      };
      environmentFile = config.sops.templates.open-webui-secrets.path;
    };

    custom = {
      system.packages.unfreePackages = [
        "open-webui"
      ];
      services = {
        caddy.hosts = {
          open-webui = {
            subdomain = "chat";
            target = ":${toString cfg.port}";
          };
        };
        #postgresql.users = [ "open-webui" ];
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/open-webui";
          user = "open-webui";
          group = "open-webui";
          mode = "0700";
        }
      ];
    };

    sops = {
      templates.open-webui-secrets = {
        content = ''
          OAUTH_CLIENT_ID=${config.sops.placeholder."${config.networking.hostName}/oidc/open-webui/id"}
          OAUTH_CLIENT_SECRET=${
            config.sops.placeholder."${config.networking.hostName}/oidc/open-webui/secret"
          }
        '';
        owner = "open-webui";
        mode = "0600";
      };
      secrets = {
        "${config.networking.hostName}/oidc/open-webui/secret".owner = "open-webui";
        "${config.networking.hostName}/oidc/open-webui/secret-hash".owner = "authelia-main";
        "${config.networking.hostName}/oidc/open-webui/id".owner = "open-webui";
        "authelia-${config.networking.hostName}/oidc/open-webui/id" = {
          key = "${config.networking.hostName}/oidc/open-webui/id";
          owner = "authelia-main";
        };
      };
    };
  };
}
