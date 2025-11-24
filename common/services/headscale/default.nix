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

  policyContent = builtins.toJSON (
    import ./acl-config.nix {
      inherit config lib;
    }
  );

  headscale-wireguard-only = pkgs.headscale.overrideAttrs (oldAttrs: {
    pname = "headscale";

    src = pkgs.fetchFromGitHub {
      owner = "iridated";
      repo = "headscale";
      rev = "wireguard-only-peers";
      hash = "sha256-b2E6Q1ZKNCewBwUhPM2YU85VFnMvx6EjeFNXcWt2wg4=";
    };

    vendorHash = "sha256-VOi4PGZ8I+2MiwtzxpKc/4smsL5KcH/pHVkjJfAFPJ0=";
  });
in
{
  options.custom.services.headscale = {
    enable = custom.enableOption;

    forAuth = mkOption {
      type = types.bool;
      default = cfg.enable;
    };

    port = mkOption {
      type = types.port;
      default = 8090;
    };

    nameservers = mkOption {
      type = types.listOf types.str;
      default = [ "194.242.2.2" ];
    };

    netDomain = mkOption {
      type = types.str;
      default = config.custom.cfg.domains.local;
    };
  };

  config = mkMerge [
    (mkIf cfg.forAuth {
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

      systemd.services = {
        headscale =
          let
            deps = [ "${config.custom.services.authelia.name}.service" ];
          in
          {
            after = deps;
            wants = deps;
          };
      };

      services = {
        headscale = {
          enable = true;
          package = headscale-wireguard-only;
          address = "0.0.0.0";
          inherit (cfg) port;
          settings = {
            database = {
              type = "postgres";
              postgres = {
                host = "/run/postgresql";
                name = "headscale";
                user = "headscale";
              };
            };
            dns = {
              magic_dns = true;
              base_domain = cfg.netDomain;
              nameservers = {
                global = cfg.nameservers;
                split = {
                  "${cfg.netDomain}" = [ config.custom.services.tailscale.ip ];
                };
              };
            };
            oidc = {
              issuer = "https://${custom.mkServiceDomain config "authelia-public"}";
              # TODO: read from secrets
              client_id = "z1LAjliTV6kTSNH.lYCg3J1LOy3PU9pJvJscUbzw9xqSG9tr21vDJrfpnPzpPGJjf1wjxwZC";
              client_secret_path = custom.mkSecretPath config "oidc/headscale/secret" "headscale";
              pkce.enabled = true;
            };
            policy = {
              inherit (config.sops.templates.headscale-acl-config) path;
            };
            server_url = "https://${serviceDomain}";
          };
        };
      };

      sops = {
        templates.headscale-acl-config = {
          content = policyContent;
          owner = "headscale";
          restartUnits = [
            "headscale.service"
          ];
        };
      };

      custom = {
        services = {
          caddy.hosts = {
            headscale = {
              target = ":${toString cfg.port}";
              ca = "public";
            };
          };
          postgresql.users = [ "headscale" ];
        };
        system = {
          sops.secrets =
            let
              mkUserSecret = key: {
                path = "tailscale/acl/users/${key}";
                owner = "headscale";
                source = "common";
              };
            in
            [
              (mkUserSecret "a")
              (mkUserSecret "b")
            ];
          persistence.config = {
            directories = [ "/var/lib/headscale" ];
          };
        };
      };
    })
  ];
}
