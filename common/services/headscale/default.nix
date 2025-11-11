{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.headscale;
  serviceDomain = custom.mkServiceDomain config "headscale";
in
{
  options.custom.services.headscale = {
    enable = custom.enableOption;

    forOidc = mkOption {
      type = types.bool;
      default = cfg.enable;
    };

    subdomain = mkOption {
      type = types.str;
      default = "net";
    };

    port = mkOption {
      type = types.port;
      default = 8090;
    };

    nameservers = mkOption {
      type = types.listOf types.str;
      default = [ "9.9.9.9" ];
    };
  };

  config = mkMerge [
    (mkIf cfg.forOidc {
      custom.services.authelia.clients.headscale = {
        name = "Headscale";
        redirectUris = [
          "https://${serviceDomain}/oidc/callback"
        ];
        makeSecrets = cfg.enable;
      };
    })
    (mkIf cfg.enable {
      users.users.headscale = {
        extraGroups = [ "postgres" ];
      };

      services = {
        headscale = {
          enable = true;
          address = "0.0.0.0";
          inherit (cfg) port;
          settings = {
            database = {
              type = "postgres";
              postgres = {
                password_file = pkgs.writeTextFile {
                  name = "headscale-password";
                  text = "headscale";
                };
                host = "/run/postgresql";
                port = null;
                name = "headscale";
                user = "headscale";
              };
            };
            dns = {
              magic_dns = true;
              base_domain = "net.local";
              nameservers.global = cfg.nameservers;
            };
            oidc = {
              issuer = "https://${custom.mkServiceDomain config "authelia"}";
              # TODO: read from secrets
              client_id = "z1LAjliTV6kTSNH.lYCg3J1LOy3PU9pJvJscUbzw9xqSG9tr21vDJrfpnPzpPGJjf1wjxwZC";
              client_secret_path = custom.mkSecretPath config "oidc/headscale/secret" "headscale";
              pkce.enabled = true;
            };
            server_url = "https://${serviceDomain}";
          };
        };
      };

      custom = {
        services = {
          caddy.hosts = {
            headscale.target = ":${toString cfg.port}";
          };
          postgresql.users = [ "headscale" ];
        };
        system = {
          persistence.config = {
            directories = [ "/var/lib/headscale" ];
          };
        };
      };
    })
  ];
}
