{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.step-ca;
  serviceDomain = custom.mkServiceDomain config "step-ca";
in
{
  options.custom.services.step-ca = {
    enable = custom.enableOption;

    role = mkOption {
      type = types.enum [
        "server"
        "client"
      ];
    };

    port = mkOption {
      type = types.port;
      default = 8444;
    };

    certs = mkOption {
      type = types.submodule {
        options = {
          intermediate = mkOption {
            type = types.path;
            default = ./certs/intermediate.crt;
          };
          root = mkOption {
            type = types.path;
            default = ./certs/root.crt;
          };
        };
      };
      default = { };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      security.pki.certificateFiles = [
        cfg.certs.intermediate
        cfg.certs.root
      ];
    }
    (mkIf (cfg.role == "server") {
      systemd.services = {
        step-ca = {
          serviceConfig = {
            DynamicUser = mkForce false;
            User = "step-ca";
            Group = "step-ca";
          };
        };
      };

      services.step-ca = {
        enable = true;
        address = "127.0.0.1";
        inherit (cfg) port;
        intermediatePasswordFile = custom.mkSecretPath config "step-ca/intermediate/password" "step-ca";
        settings = {
          dnsNames = [ serviceDomain ];
          root = ./certs/root.crt;
          crt = ./certs/intermediate.crt;
          key = custom.mkSecretPath config "step-ca/intermediate/key" "step-ca";
          db = {
            type = "badgerv2";
            dataSource = "/var/lib/step-ca";
          };
          authority = {
            provisioners = [
              {
                type = "ACME";
                name = "acme";
                forceCN = true;
              }
            ];
          };
        };
      };

      custom = {
        services = {
          caddy.hosts = {
            step-ca = {
              # kind of weird to do it like this, as we can't connect to localhost
              target = "https://${serviceDomain}:${toString cfg.port}";
              ca = "public";
            };
          };
        };
        system = {
          sops.secrets = [
            {
              path = "step-ca/intermediate/password";
              owner = "step-ca";
            }
            {
              path = "step-ca/intermediate/key";
              owner = "step-ca";
            }
          ];
          persistence.config = {
            directories = [
              {
                directory = "/var/lib/step-ca";
                user = "step-ca";
                group = "step-ca";
                mode = "0700";
              }
            ];
          };
        };
      };
    })
  ]);
}
