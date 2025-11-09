{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.caddy;
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
                type = types.nullOr types.str;
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
                type = types.str;
                default = "";
                description = "additional directives";
              };
              type = mkOption {
                type = types.enum [
                  "http"
                  "root"
                ];
                default = "http";
              };
            };
          }
        )
      );
      default = { };
      description = "services to reverse proxy or serve statically";
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

      virtualHosts = mapAttrs' (_: service: {
        name = if service.subdomain != null then "${service.subdomain}.${cfg.domain}" else cfg.domain;
        value = {
          logFormat = ''
            output discard
          '';
          extraConfig = ''
            ${concatStringsSep "\n" (map (snippet: "import ${snippet}") service.import)}
            ${
              if service.type == "root" then
                ''
                  root * ${toString service.target}
                  file_server
                ''
              else
                ''
                  reverse_proxy ${toString service.target}
                ''
            }
            ${service.extra}
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

    custom.system = {
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

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
      ];
    };
  };
}
