{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.radicale;
in
{
  options.custom.services.radicale = {
    enable = mkEnableOption "Radicale CalDAV & CardDAV backend";
    domain = mkOption {
      type = types.str;
    };
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
          ldap_uri = "ldap://localhost:${toString config.custom.services.lldap.ports.ldap}";
          ldap_base = "dc=f1nn,dc=space";
          ldap_reader_dn = "uid=bind,ou=people,dc=f1nn,dc=space";
          ldap_secret = "binduser";
          ldap_filter = "(&(|(uid={0})(mail={0})(firstName={0}))(objectClass=person))";
          ldap_user_attribute = "uid";
          lc_username = true;
        };
      };
    };

    custom.services = {
      caddy.hosts.radicale = {
        subdomain = "cal";
        target = ":${toString cfg.port}";
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/radicale";
          user = "radicale";
          group = "radicale";
          mode = "0700";
        }
      ];
    };

    custom.services.restic.paths = [
      "/var/lib/radicale"
    ];
  };
}
