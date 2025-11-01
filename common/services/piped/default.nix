{
  config,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.piped;

  serviceDomain = custom.mkServiceDomain config "piped";
in
{
  options.custom.services.piped = {
    enable = custom.enableOption;

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

  imports = [
    inputs.piped.nixosModules.default
  ];

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
      # TODO: "Exception in thread "main" java.lang.UnsatisfiedLinkError: /tmp/libreqwestXXX.so: /tmp/libreqwestXXX.so: failed to map segment from shared object"
      piped-backend = {
        enable = true;
        settings = {
          API_URL = "https://api.${serviceDomain}";
          PROXY_PART = "https://proxy.${serviceDomain}";
          FRONTEND_URL = "https://${serviceDomain}";

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
        publicBackendUrl = "https://api.${serviceDomain}";
        publicFrontendUrl = "https://${serviceDomain}";
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
