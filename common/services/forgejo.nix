{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.forgejo;
  subdomain = "code";
in
{
  options.custom.services.forgejo = {
    enable = custom.enableOption;

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
          DOMAIN = "${subdomain}.${config.custom.services.caddy.domain}";
          ROOT_URL = "https://${subdomain}.${config.custom.services.caddy.domain}/";
          HTTP_PORT = cfg.port;
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
        openid = {
          ENABLE_OPENID_SIGNIN = true;
          ENABLE_OPENID_SIGNUP = true;
          WHITELISTED_URIS = "auth.${config.custom.services.caddy.domain}";
        };
      };
    };

    # ensure admin account
    systemd.services.forgejo.preStart =
      let
        adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
        pwd = config.sops.secrets."${config.networking.hostName}/forgejo/admin-password";
        user = "finn";
      in
      ''
        ${adminCmd} create --admin --email "${config.custom.system.user.email}" --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
        ## uncomment this line to change an admin user which was already created
        # ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
      '';

    custom.services.caddy.hosts = {
      forgejo = {
        inherit subdomain;
        target = ":${toString cfg.port}";
      };
    };

    custom.system.persistence.config = {
      directories = [
        {
          directory = "/var/lib/forgejo";
          user = "forgejo";
          group = "forgejo";
          mode = "0700";
        }
      ];
    };

    sops = {
      secrets = {
        "${config.networking.hostName}/forgejo/admin-password".owner = "forgejo";

        "${config.networking.hostName}/oidc/forgejo/secret".owner = "forgejo";
        "${config.networking.hostName}/oidc/forgejo/secret-hash".owner = "authelia-main";
        "${config.networking.hostName}/oidc/forgejo/id".owner = "forgejo";
        "authelia-${config.networking.hostName}/oidc/forgejo/id" = {
          key = "${config.networking.hostName}/oidc/forgejo/id";
          owner = "authelia-main";
        };
      };
    };
  };
}
