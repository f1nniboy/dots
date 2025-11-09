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
  };

  config = mkMerge [
    (mkIf cfg.forOidc {
      custom.services.authelia.clients.headscale = {
        name = "Headscale";
        id = "headscale";
        requirePkce = true;
        redirectUris = [
          "https://${serviceDomain}/oidc/callback"
        ];
        makeSecrets = true;
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
              magic_dns = false;
              nameservers.global = [
                "1.1.1.1"
                "8.8.8.8"
              ];
            };
            oidc = {
              issuer = "https://${custom.mkServiceDomain config "authelia"}";
              client_id = "z1LAjliTV6kTSNH.lYCg3J1LOy3PU9pJvJscUbzw9xqSG9tr21vDJrfpnPzpPGJjf1wjxwZC"; # TODO: read from secrets
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
          authelia.clients.headscale.makeSecrets = true;
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
