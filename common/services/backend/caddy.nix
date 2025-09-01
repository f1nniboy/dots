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
    enable = mkEnableOption "reverse proxy with Caddy";
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
              description = "Subdomain for the service";
            };
            target = mkOption {
              type = types.str;
            };
            import = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "List of Caddy snippets to import for this host";
            };
            extra = mkOption {
              type = types.str;
              default = "";
              description = "Additional configuration directives";
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
      description = "Services to reverse proxy or serve statically";
    };
  };

  config = mkIf cfg.enable {
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

    systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates.caddy-secrets.path;

    services.caddy = {
      enable = true;
      inherit (config.custom.user) email;

      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/porkbun@v0.3.1" ];
        hash = "sha256-g/Nmi4X/qlqqjY/zoG90iyP5Y5fse6Akr8exG5Spf08=";
      };

      globalConfig = ''
        acme_dns porkbun {
          api_key {env.PORKBUN_API_KEY}
          api_secret_key {env.PORKBUN_API_SECRET_KEY}
        }
      '';

      virtualHosts = mapAttrs' (name: service: {
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

    environment.persistence."/nix/persist" = {
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
}
