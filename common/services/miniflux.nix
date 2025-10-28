{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.miniflux;
in
{
  options.custom.services.miniflux = {
    enable = custom.enableOption;
    domain = mkOption {
      type = types.str;
    };
    port = mkOption {
      type = types.port;
      default = 8083;
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.miniflux = {
        isSystemUser = true;
        group = "miniflux";
        extraGroups = [ "postgres" ];
      };
      groups.miniflux = { };
    };

    # TODO: error reading secret file for key OAUTH2_CLIENT_ID_FILE: open /run/secrets/lab/oidc/miniflux/id: permission denied
    services.miniflux = {
      enable = true;
      adminCredentialsFile = config.sops.templates.miniflux-creds.path;
      # ref: https://miniflux.app/docs/configuration.html
      config =
        let
          inherit (config.sops) secrets;
        in
        {
          BASE_URL = "https://news.${config.custom.services.caddy.domain}";
          LISTEN_ADDR = "127.0.0.1:${toString cfg.port}";

          FETCH_YOUTUBE_WATCH_TIME = "1";

          OAUTH2_PROVIDER = "oidc";
          OAUTH2_CLIENT_ID_FILE = secrets."${config.networking.hostName}/oidc/miniflux/id".path;
          OAUTH2_CLIENT_SECRET_FILE = secrets."${config.networking.hostName}/oidc/miniflux/secret".path;
          OAUTH2_REDIRECT_URL = "https://news.${config.custom.services.caddy.domain}/oauth2/oidc/callback";
          OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://auth.${config.custom.services.caddy.domain}";
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
          ADMIN_PASSWORD="${config.sops.placeholder."${config.networking.hostName}/miniflux/admin-password"}"
        '';
        owner = "miniflux";
      };
      secrets = {
        "${config.networking.hostName}/miniflux/admin-password".owner = "miniflux";

        "authelia-${config.networking.hostName}/oidc/miniflux/id" = {
          key = "${config.networking.hostName}/oidc/miniflux/id";
          owner = "authelia-main";
        };
        "${config.networking.hostName}/oidc/miniflux/id".owner = "miniflux";

        "${config.networking.hostName}/oidc/miniflux/secret".owner = "miniflux";
        "${config.networking.hostName}/oidc/miniflux/secret-hash".owner = "authelia-main";
      };
    };

    custom.services = {
      caddy.hosts.miniflux = {
        subdomain = "news";
        target = ":${toString cfg.port}";
      };
      postgresql.users = [ "miniflux" ];
    };
  };
}
