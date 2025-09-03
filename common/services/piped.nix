{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.piped;
in
{
  options.custom.services.piped = {
    enable = mkEnableOption "Piped YouTube frontend & proxy";
    subdomain = mkOption {
      type = types.str;
      default = "yt";
    };
    ports = mkOption {
      type = types.submodule {
        options = {
          proxy = mkOption {
            type = types.port;
            default = 14300;
          };
          frontend = mkOption {
            type = types.port;
            default = 14301;
          };
          api = mkOption {
            type = types.port;
            default = 14302;
          };
        };
      };
      default = { };
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.piped = {
        isSystemUser = true;
        group = "piped";
        extraGroups = [ "postgres" ];
      };
      groups.piped = { };
    };

    systemd.services.piped-backend = {
      serviceConfig = {
        DynamicUser = mkForce false;
        User = mkForce "piped";
        Group = mkForce "piped";
      };
    };

    services = {
      piped-backend = {
        enable = true;
        settings = {
          API_URL = "https://api.${cfg.subdomain}.${config.custom.services.caddy.domain}";
          PROXY_PART = "https://proxy.${cfg.subdomain}.${config.custom.services.caddy.domain}";
          FRONTEND_URL = "https://${cfg.subdomain}.${config.custom.services.caddy.domain}";
          "hibernate.connection.url" = "jdbc:postgresql://127.0.0.1:5432/piped?user=piped";
        };
      };
      piped-proxy = {
        enable = true;
        listenAddress = "127.0.0.1:${toString cfg.ports.proxy}";
      };
      piped-frontend = {
        enable = true;
        listenPort = cfg.ports.frontend;
        publicBackendUrl = "https://api.${cfg.subdomain}.${config.custom.services.caddy.domain}";
        publicFrontendUrl = "https://${cfg.subdomain}.${config.custom.services.caddy.domain}";
      };
    };

    custom.services = {
      caddy.hosts = {
        piped-backend = {
          subdomain = "api.${cfg.subdomain}";
          target = "127.0.0.1:${toString cfg.ports.api}";
        };
        piped-proxy = {
          subdomain = "proxy.${cfg.subdomain}";
          target = ":${toString cfg.ports.proxy}";
        };
        piped-frontend = {
          inherit (cfg) subdomain;
          target = ":${toString cfg.ports.frontend}";
        };
      };
    };
  };
}
