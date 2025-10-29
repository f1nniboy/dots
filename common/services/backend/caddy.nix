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
      description = "Default base domain for reverse proxy services";
    };
    hosts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            subdomain = mkOption {
              type = types.str;
              description = "subdomain for the service";
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
        name = "${service.subdomain}.${cfg.domain}";
        value = {
          logFormat = mkForce ''
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
          PORKBUN_API_KEY=${config.sops.placeholder."${config.networking.hostName}/caddy/porkbun/api-key"}
          PORKBUN_API_SECRET_KEY=${
            config.sops.placeholder."${config.networking.hostName}/caddy/porkbun/api-secret-key"
          }
        '';
        owner = "caddy";
      };
      secrets = {
        "${config.networking.hostName}/caddy/porkbun/api-key".owner = "caddy";
        "${config.networking.hostName}/caddy/porkbun/api-secret-key".owner = "caddy";
      };
    };

    custom.system.persistence.config = {
      directories = [
        {
          directory = "/var/lib/caddy";
          user = "caddy";
          group = "caddy";
          mode = "0700";
        }
      ];
    };

    #networking.firewall = {
    #  allowedTCPPorts = [ 80 443 ];
    #};
  };
}
