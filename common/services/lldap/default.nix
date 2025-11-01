{
  config,
  lib,
  vars,
  ...
}:
with lib;
let
  cfg = config.custom.services.lldap;
in
{
  options.custom.services.lldap = {
    enable = custom.enableOption;

    subdomain = mkOption {
      type = types.str;
      default = "ldap";
    };

    ports = mkOption {
      type = types.submodule {
        options = {
          http = mkOption {
            type = types.port;
            default = 17170;
          };
          ldap = mkOption {
            type = types.port;
            default = 3890;
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
      };

    services = {
      lldap =
        let
          mkSecret = path: config.sops.secrets."${config.networking.hostName}/lldap/${path}".path;
        in
        {
          enable = true;
          settings = {
            http_host = "127.0.0.1";
            http_port = cfg.ports.http;
            database_url = "postgres://lldap?host=/var/run/postgresql";
            ldap_port = cfg.ports.ldap;
            ldap_base_dn = custom.domainToDn vars.lab.domain;
            ldap_user_pass_file = mkSecret "admin-password";
            force_ldap_user_pass_reset = "always";
            jwt_secret_file = mkSecret "jwt-secret";
          };
          environment = {
            LLDAP_KEY_SEED_FILE = mkSecret "key-seed";
          };
        };
    };

    sops.secrets = {
      "${config.networking.hostName}/lldap/admin-password".owner = "lldap";
      "${config.networking.hostName}/lldap/jwt-secret".owner = "lldap";
      "${config.networking.hostName}/lldap/key-seed".owner = "lldap";
    };

    custom.services = {
      caddy.hosts = {
        lldap.target = ":${toString cfg.ports.http}";
      };
      postgresql.users = [ "lldap" ];
    };
  };
}
