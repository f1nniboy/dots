{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.caddy;
  global = config.custom.cfg;
in
{
  options.custom.services.caddy = {
    enable = custom.enableOption;
    hosts = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              sub = mkOption {
                type = types.nullOr types.str;
                default = global.services."${name}".sub;
              };
              ca = mkOption {
                type = types.enum [
                  "public"
                  "self"
                ];
                default = "self";
              };
              target = mkOption {
                type = types.nullOr types.str;
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
                  "proxy"
                  "root"
                  "custom"
                ];
                default = "proxy";
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

      # snippet that can be imported to enable authelia in front of a service
      # ref: https://www.authelia.com/integration/proxies/caddy/#subdomain
      extraConfig = ''
        (auth) {
          forward_auth https://${custom.mkServiceDomain config "authelia"} {
            header_up Host {upstream_hostport}
            uri /api/authz/forward-auth
            copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
          }
        }
      '';

      virtualHosts = mapAttrs' (name: host: {
        name = custom.mkServiceDomain config name;
        value = {
          logFormat = ''
            output discard
          '';
          extraConfig =
            let
              configs = [
                # imports
                (concatStringsSep "\n" (map (snippet: "import ${snippet}") host.import))

                # service type "root"
                (optional (host.type == "root") ''
                  root * ${toString host.target}
                  header {
                    -Last-Modified
                  }
                  file_server {
                    etag_file_extensions .etag
                  }
                '')

                # service type "proxy"
                (optional (host.type == "proxy") ''
                  reverse_proxy ${toString host.target}
                '')

                # lets encrypt certs
                (optional (host.ca == "public") ''
                  tls {
                    dns porkbun {
                      api_key {env.PORKBUN_API_KEY}
                      api_secret_key {env.PORKBUN_API_SECRET_KEY}
                    }
                  }
                '')

                # self-signed certs
                (optional (host.ca == "self") ''
                  tls {
                    ca https://${custom.mkServiceDomain config "step-ca"}/acme/acme/directory
                  }
                '')

                # additional config
                host.extra
              ];

              # flatten the list of lists and filter out empty strings
              flattened = lib.flatten configs;
              nonEmpty = lib.filter (s: s != "" && s != null) flattened;
            in
            lib.concatStringsSep "\n\n" nonEmpty;
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
            source = "common";
          }
          {
            path = "porkbun/api-secret-key";
            owner = "caddy";
            source = "common";
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
