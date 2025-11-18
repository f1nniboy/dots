{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.miniflux;
  serviceDomain = custom.mkServiceDomain config "miniflux";
in
{
  options.custom.services.miniflux = {
    enable = custom.enableOption;

    forAuth = mkOption {
      type = types.bool;
      default = cfg.enable;
    };

    port = mkOption {
      type = types.port;
      default = 8083;
    };
  };

  config = mkMerge [
    (mkIf cfg.forAuth {
      custom.services.authelia.clients.miniflux = {
        name = "Miniflux";
        redirectUris = [
          "https://${serviceDomain}/oauth2/oidc/callback"
        ];
        makeSecrets = cfg.enable;
      };
    })
    (mkIf cfg.enable {
      users = {
        users.miniflux = {
          isSystemUser = true;
          group = "miniflux";
          extraGroups = [ "postgres" ];
        };
        groups.miniflux = { };
      };

      services.miniflux = {
        enable = true;
        adminCredentialsFile = config.sops.templates.miniflux-creds.path;
        # ref: https://miniflux.app/docs/configuration.html
        config = {
          BASE_URL = "https://${serviceDomain}";
          LISTEN_ADDR = "127.0.0.1:${toString cfg.port}";

          FETCH_YOUTUBE_WATCH_TIME = "1";

          OAUTH2_PROVIDER = "oidc";
          OAUTH2_CLIENT_ID_FILE = custom.mkSecretPath config "oidc/miniflux/id" "miniflux";
          OAUTH2_CLIENT_SECRET_FILE = custom.mkSecretPath config "oidc/miniflux/secret" "miniflux";
          OAUTH2_REDIRECT_URL = "https://${serviceDomain}/oauth2/oidc/callback";
          OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://${custom.mkServiceDomain config "authelia"}";
          OAUTH2_OIDC_PROVIDER_NAME = "Authelia";
          OAUTH2_USER_CREATION = "1";
          DISABLE_LOCAL_AUTH = "true";
        };
      };

      systemd.services.miniflux =
        let
          deps = [ "postgresql.service" ];
        in
        {
          requires = deps;
          after = deps;
          serviceConfig = {
            DynamicUser = mkForce false;
            User = mkForce "miniflux";
            Group = mkForce "miniflux";
          };
        };

      sops = {
        templates.miniflux-creds = {
          content = ''
            ADMIN_USERNAME="admin"
            ADMIN_PASSWORD="${custom.mkSecretPlaceholder config "miniflux/admin-password" "miniflux"}"
          '';
          owner = "miniflux";
        };
      };

      custom = {
        system = {
          sops.secrets = [
            {
              path = "miniflux/admin-password";
              owner = "miniflux";
            }
          ];
        };
        services = {
          caddy.hosts = {
            miniflux.target = ":${toString cfg.port}";
          };
          postgresql.users = [ "miniflux" ];
        };
      };

      security.apparmor.policies."bin.miniflux".profile =
        let
          pkg = config.services.miniflux.package;
        in
        mkForce ''
          include <tunables/global>
          profile ${pkg}/bin/miniflux flags=(attach_disconnected) {
            include <abstractions/base>
            include <abstractions/nameservice>
            include <abstractions/ssl_certs>
            include "${pkgs.apparmorRulesFromClosure { name = "miniflux"; } pkg}"
            r ${pkg}/bin/miniflux,
            r @{sys}/kernel/mm/transparent_hugepage/hpage_pmd_size,
            rw /run/miniflux/**,

            # make secrets & db accessible
            r /run/secrets.d/*/miniflux-oidc/miniflux/id,
            r /run/secrets.d/*/miniflux-oidc/miniflux/secret,
            rw /run/postgresql/*,
          }
        '';
    })
  ];
}
