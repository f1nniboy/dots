{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.acme;
in
{
  options.custom.services.acme = {
    enable = custom.enableOption;
    domains = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            group = mkOption {
              type = types.nullOr types.str;
            };
          };
        }
      );
      default = { };
      description = "domains to request a certificate for";
    };
  };

  config = mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults = {
        dnsProvider = "porkbun";
        environmentFile = config.sops.templates.acme-porkbun-secrets.path;
        inherit (config.custom.system.user) email;
      };
      certs = cfg.domains;
    };

    sops = {
      templates.acme-porkbun-secrets = {
        content = ''
          PORKBUN_API_KEY=${custom.mkSecretPlaceholder config "porkbun/api-key" "acme"}
          PORKBUN_API_SECRET_KEY=${custom.mkSecretPlaceholder config "porkbun/api-secret-key" "acme"}
        '';
        owner = "acme";
      };
    };

    custom.system = {
      sops.secrets = [
        {
          path = "porkbun/api-key";
          owner = "acme";
        }
        {
          path = "porkbun/api-secret-key";
          owner = "acme";
        }
      ];
      persistence.config = {
        directories = [
          {
            directory = "/var/lib/acme";
            user = "acme";
            group = "acme";
            mode = "0770";
          }
        ];
      };
    };
  };
}
