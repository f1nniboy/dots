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
      description = "Domains to request a certificate for";
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
          PORKBUN_API_KEY=${config.sops.placeholder."common/acme/porkbun/api-key"}
          PORKBUN_SECRET_API_KEY=${config.sops.placeholder."common/acme/porkbun/api-secret-key"}
        '';
        owner = "acme";
      };
      secrets = {
        "common/acme/porkbun/api-key".owner = "acme";
        "common/acme/porkbun/api-secret-key".owner = "acme";
      };
    };

    custom.system.persistence.config = {
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
}
