{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.paperless;

  docsDir = "/fun/media/docs";
  serviceDomain = custom.mkServiceDomain config "paperless";
in
{
  options.custom.services.paperless = {
    enable = custom.enableOption;

    subdomain = mkOption {
      type = types.str;
      default = "paper";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.paperless-ngx
    ];

    users.users.paperless = {
      extraGroups = [
        "postgres"
        "redis-paperless"
      ];
    };

    services = {
      paperless = {
        enable = true;
        mediaDir = docsDir;
        consumptionDir = "/fun/media/shares/paperless";
        database.createLocally = false;
        passwordFile = config.sops.secrets."${config.networking.hostName}/paperless/admin-password".path;
        domain = ""; # only needed if services.paperless.configureNginx is enabled
        settings = {
          PAPERLESS_DBHOST = "/run/postgresql";
          PAPERLESS_REDIS = "redis+socket:///run/redis-paperless/redis.sock";
          PAPERLESS_URL = mkForce "https://${serviceDomain}";
          PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
          PAPERLESS_DISABLE_REGULAR_LOGIN = true;
          PAPERLESS_SOCIAL_AUTO_SIGNUP = true;
        };
      };
      samba = {
        settings = {
          "paperless" = {
            "path" = "/fun/media/shares/paperless";
            "browseable" = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "force user" = "paperless";
            "force group" = "paperless";
          };
        };
      };
    };

    systemd.services.paperless-web.serviceConfig.EnvironmentFile =
      config.sops.templates.paperless-secrets.path;

    sops = {
      templates.paperless-secrets = {
        content = ''
          PAPERLESS_SOCIALACCOUNT_PROVIDERS='{
              "openid_connect": {
                  "OAUTH_PKCE_ENABLED": true,
                  "APPS": [
                      {
                          "provider_id": "authelia",
                          "name": "Authelia",
                          "client_id": "${
                            config.sops.placeholder."${config.networking.hostName}/oidc/paperless/id"
                          }",
                          "secret": "${
                            config.sops.placeholder."${config.networking.hostName}/oidc/paperless/secret"
                          }",
                          "settings": {
                              "server_url": "https://${custom.mkServiceDomain config "authelia"}/.well-known/openid-configuration",
                              "token_auth_method": "client_secret_basic"
                          }
                      }
                  ]
              }
          }'
        '';
        owner = "paperless";
      };
      secrets = {
        "${config.networking.hostName}/paperless/admin-password".owner = "paperless";

        "${config.networking.hostName}/oidc/paperless/secret".owner = "paperless";
        "${config.networking.hostName}/oidc/paperless/secret-hash".owner = "authelia-main";
        "${config.networking.hostName}/oidc/paperless/id".owner = "paperless";
        "authelia-${config.networking.hostName}/oidc/paperless/id" = {
          key = "${config.networking.hostName}/oidc/paperless/id";
          owner = "authelia-main";
        };
      };
    };

    custom = {
      services = {
        postgresql.users = [ "paperless" ];
        redis.servers = [ "paperless" ];
      };

      services = {
        caddy.hosts = {
          paperless.target = ":${toString config.services.paperless.port}";
        };
        authelia.clients = [
          {
            name = "Paperless";
            id = "paperless";
            policy = "one_factor";
            requirePkce = true;
            redirectUris = [
              "https://${serviceDomain}/accounts/oidc/authelia/login/callback/"
            ];
          }
        ];
        restic = {
          paths = [
            "/var/lib/paperless"
            docsDir
          ];
          exclude = [
            "${docsDir}/documents/thumbnails"
            "/var/lib/paperless/log"
          ];
        };
      };

      system.persistence.config = {
        directories = [
          {
            directory = "/var/lib/paperless";
            user = "paperless";
            group = "paperless";
            mode = "0700";
          }
        ];
      };
    };
  };
}
