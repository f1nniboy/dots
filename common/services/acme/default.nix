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
        server = "https://${custom.mkServiceDomain config "step-ca"}/acme/acme/directory";
        webroot = "/var/lib/acme/empty"; # doesn't matter, step-ca doesn't do any checks
        inherit (config.custom.system.user) email;
      };
      certs = cfg.domains;
    };

    custom.system = {
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
