{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.radicale;
  dn = custom.domainToDn config.custom.cfg.domains.public;
in
{
  options.custom.services.radicale = {
    enable = custom.enableOption;

    port = mkOption {
      type = types.port;
      default = 5232;
    };
  };

  config = mkIf cfg.enable {
    services.radicale = {
      enable = true;
      settings = {
        server = {
          hosts = [ "127.0.0.1:${toString cfg.port}" ];
        };
        auth = {
          type = "ldap";
          ldap_uri = "ldap://jupiter";
          ldap_base = dn;
          ldap_reader_dn = "uid=bind:radicale,ou=people,${dn}";
          ldap_secret = "binduser";
          ldap_filter = "(&(|(uid={0})(mail={0})(firstName={0}))(objectClass=person))";
          ldap_user_attribute = "uid";
          lc_username = true;
        };
      };
    };

    custom = {
      services = {
        caddy.hosts = {
          radicale.target = ":${toString cfg.port}";
        };
      };

      system.persistence.config = {
        directories = [
          {
            directory = "/var/lib/radicale";
            user = "radicale";
            group = "radicale";
            mode = "0700";
          }
        ];
      };

      services.restic.paths = [
        "/var/lib/radicale"
      ];
    };
  };
}
