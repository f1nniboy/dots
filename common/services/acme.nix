{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.acme;
in
{
  options.custom.services.acme = {
    enable = mkEnableOption "ACME certificate retrieval";
    domains = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = { };
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

    environment.persistence."/nix/persist" = {
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
