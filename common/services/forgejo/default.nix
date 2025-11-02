{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
with lib;
let
  cfg = config.custom.services.forgejo;
  serviceDomain = custom.mkServiceDomain config "forgejo";
in
{
  options.custom.services.forgejo = {
    enable = custom.enableOption;

    subdomain = mkOption {
      type = types.str;
      default = "code";
    };

    port = mkOption {
      type = types.port;
      default = 3000;
    };
  };

  config = mkIf cfg.enable {
    users.users.forgejo = {
      extraGroups = [ "postgres" ];
    };

    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;
      database = {
        type = "postgres";
      };
      lfs.enable = true;
      settings = {
        server = {
          DOMAIN = serviceDomain;
          ROOT_URL = "https://${serviceDomain}/";
          HTTP_PORT = cfg.port;
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
        openid = {
          ENABLE_OPENID_SIGNIN = true;
          ENABLE_OPENID_SIGNUP = true;
          WHITELISTED_URIS = custom.mkServiceDomain config "authelia";
        };
      };
    };

    # ensure admin account
    systemd.services.forgejo.preStart =
      let
        adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
        secretPath = custom.mkSecretPath config "forgejo/admin-password" "forgejo";
        user = vars.user.nick;
      in
      ''
        ${adminCmd} create --admin --email "${config.custom.system.user.email}" --username ${user} --password "$(tr -d '\n' < ${secretPath})" || true
        ## uncomment this line to change an admin user which was already created
        # ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${secretPath})" || true
      '';

    custom = {
      system = {
        sops.secrets = [
          {
            path = "forgejo/admin-password";
            owner = "forgejo";
          }
        ];

        persistence.config = {
          directories = [
            {
              directory = "/var/lib/forgejo";
              user = "forgejo";
              group = "forgejo";
              mode = "0700";
            }
          ];
        };
      };

      services = {
        caddy.hosts = {
          forgejo.target = ":${toString cfg.port}";
        };
        authelia.clients = [
          {
            name = "Forgejo";
            id = "forgejo";
            requirePkce = true;
            redirectUris = [
              "https://${serviceDomain}/user/oauth2/Authelia/callback"
            ];
          }
        ];
      };
    };
  };
}
