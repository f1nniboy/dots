{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.paperless;

  docsDir = "/fun/media/docs";
  serviceDomain = custom.mkServiceDomain config "paperless";
in
{
  options.custom.services.paperless = {
    enable = custom.enableOption;

    forAuth = mkOption {
      type = types.bool;
      default = cfg.enable;
    };
  };

  config = mkMerge [
    (mkIf cfg.forAuth {
      custom.services.authelia.clients.paperless = {
        name = "Paperless";
        redirectUris = [
          "https://${serviceDomain}/accounts/oidc/authelia/login/callback/"
        ];
        makeSecrets = cfg.enable;
      };
    })
    (mkIf cfg.enable {
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
          passwordFile = custom.mkSecretPath config "paperless/admin-password" "paperless";
          domain = serviceDomain;
          settings = {
            PAPERLESS_DBHOST = "/run/postgresql";
            PAPERLESS_REDIS = "redis+socket:///run/redis-paperless/redis.sock";
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

      systemd.services = {
        paperless-web = {
          serviceConfig = {
            EnvironmentFile = config.sops.templates.paperless-secrets.path;
          };
          environment = {
            REQUESTS_CA_BUNDLE = config.custom.services.step-ca.certs.root;
          };
        };
      };

      sops = {
        templates.paperless-secrets = {
          content = ''
            PAPERLESS_SOCIALACCOUNT_PROVIDERS='${
              builtins.toJSON {
                openid_connect = {
                  OAUTH_PKCE_ENABLED = true;
                  APPS = [
                    {
                      provider_id = "authelia";
                      name = "Authelia";
                      client_id = custom.mkSecretPlaceholder config "oidc/paperless/id" "paperless";
                      secret = custom.mkSecretPlaceholder config "oidc/paperless/secret" "paperless";
                      settings = {
                        server_url = "https://${custom.mkServiceDomain config "authelia"}/.well-known/openid-configuration";
                        token_auth_method = "client_secret_basic";
                      };
                    }
                  ];
                };
              }
            }'
          '';
          owner = "paperless";
        };
      };

      custom = {
        services = {
          caddy.hosts = {
            paperless.target = ":${toString config.services.paperless.port}";
          };
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
          postgresql.users = [ "paperless" ];
          redis.servers = [ "paperless" ];
          samba.users = [ "paperless" ];
        };

        system = {
          sops.secrets = [
            {
              path = "paperless/admin-password";
              owner = "paperless";
            }
          ];
          persistence.config = {
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
    })
  ];
}
