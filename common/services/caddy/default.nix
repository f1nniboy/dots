{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.caddy;
  mkLogFile =
    service:
    "/var/log/caddy/access/${if service.subdomain != null then service.subdomain else "root"}.log";
in
{
  options.custom.services.caddy = {
    enable = custom.enableOption;
    domain = mkOption {
      type = types.str;
    };
    hosts = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              subdomain = mkOption {
                type = types.str;
                default = config.custom.services.${name}.subdomain;
              };
              target = mkOption {
                type = types.str;
              };
              import = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = "list of Caddy snippets to import for this host";
              };
              extra = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "additional directives";
              };
              type = mkOption {
                type = types.enum [
                  "http"
                  "root"
                ];
                default = "http";
              };
              enableLogging = mkOption {
                type = types.bool;
                default = false;
              };
            };
          }
        )
      );
      default = { };
      description = "hosts to reverse proxy or serve statically";
    };
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;

      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/porkbun@v0.3.1"
        ];
        hash = "sha256-j/GODingW5BhfjQRajinivX/9zpiLGgyxvAjX0+amRU=";
      };

      globalConfig = ''
        acme_dns porkbun {
          api_key {env.PORKBUN_API_KEY}
          api_secret_key {env.PORKBUN_API_SECRET_KEY}
        }
      '';

      # snippet that can be imported to enable authelia in front of a service
      # ref: https://www.authelia.com/integration/proxies/caddy/#subdomain
      extraConfig = ''
        (auth) {
            forward_auth https://auth.f1nn.space {
                header_up Host {upstream_hostport}
                uri /api/authz/forward-auth
                copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
            }
        }
      '';

      virtualHosts = mapAttrs' (_: service: {
        name = if service.subdomain != "root" then "${service.subdomain}.${cfg.domain}" else cfg.domain;
        value = {
          logFormat = ''
            ${
              if service.enableLogging then
                ''
                  output file ${mkLogFile service}
                ''
              else
                ''
                  output discard
                ''
            }
          '';
          extraConfig = ''
            ${concatStringsSep "\n" (map (snippet: "import ${snippet}") service.import)}

            ${
              if service.type == "root" then
                ''
                  header {
                    -Last-Modified
                  }
                  root * ${toString service.target}
                  file_server {
                    etag_file_extensions .etag
                  }
                ''
              else
                ''
                  reverse_proxy ${toString service.target}
                ''
            }

            ${if service.extra != null then service.extra else ""}
          '';
        };
      }) cfg.hosts;
    };

    systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates.caddy-secrets.path;

    sops = {
      templates.caddy-secrets = {
        content = ''
          PORKBUN_API_KEY=${custom.mkSecretPlaceholder config "porkbun/api-key" "caddy"}
          PORKBUN_API_SECRET_KEY=${custom.mkSecretPlaceholder config "porkbun/api-secret-key" "caddy"}
        '';
        owner = "caddy";
      };
    };

    custom = {
      system = {
        sops.secrets = [
          {
            path = "porkbun/api-key";
            owner = "caddy";
          }
          {
            path = "porkbun/api-secret-key";
            owner = "caddy";
          }
        ];
        persistence.config = {
          directories = [
            {
              directory = "/var/lib/caddy";
              user = "caddy";
              group = "caddy";
              mode = "0700";
            }
          ];
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
      ];
    };
  };
}
