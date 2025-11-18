{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.lldap;
in
{
  options.custom.services.lldap = {
    enable = custom.enableOption;

    ports = mkOption {
      type = types.submodule {
        options = {
          http = mkOption {
            type = types.port;
            default = 17170;
          };
          ldap = mkOption {
            type = types.port;
            default = 389;
          };
        };
      };
      default = { };
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.lldap = {
        group = "lldap";
        extraGroups = [ "postgres" ];
        isSystemUser = true;
      };
      groups.lldap = { };
    };

    systemd.services.lldap =
      let
        deps = [ "postgresql.service" ];
      in
      {
        after = deps;
        requires = deps;
        serviceConfig = {
          CapabilityBoundingSet = "cap_net_bind_service";
          AmbientCapabilities = "cap_net_bind_service";
          NoNewPrivileges = true;
        };
      };

    services = {
      lldap =
        let
          mkSecret = path: custom.mkSecretPath config "lldap/${path}" "lldap";
        in
        {
          enable = true;
          settings = {
            http_host = "127.0.0.1";
            http_port = cfg.ports.http;
            database_url = "postgres://lldap?host=/var/run/postgresql";
            ldap_port = cfg.ports.ldap;
            ldap_base_dn = custom.domainToDn config.custom.cfg.domains.public;
            ldap_user_pass_file = mkSecret "admin-password";
            force_ldap_user_pass_reset = "always";
            jwt_secret_file = mkSecret "jwt-secret";
          };
          environment = {
            LLDAP_KEY_SEED_FILE = mkSecret "key-seed";
          };
        };
    };

    custom = {
      system = {
        sops.secrets = [
          {
            path = "lldap/admin-password";
            owner = "lldap";
          }
          {
            path = "lldap/jwt-secret";
            owner = "lldap";
          }
          {
            path = "lldap/key-seed";
            owner = "lldap";
          }
        ];
      };
      services = {
        caddy.hosts = {
          lldap = {
            target = ":${toString cfg.ports.http}";
            ca = "public";
          };
        };
        postgresql.users = [ "lldap" ];
      };
    };
  };
}
