{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.lldap;
in
{
  options.custom.services.lldap = {
    enable = mkEnableOption "Lightweight LDAP server";

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
    systemd.services.lldap = {
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
    };

    users = {
      users.lldap = {
        group = "lldap";
        extraGroups = [ "postgres" ];
        isSystemUser = true;
      };
      groups.lldap = { };
    };

    services = {
      lldap = {
        enable = true;
        settings = {
          http_host = "127.0.0.1";
          http_port = cfg.ports.http;
          database_url = "postgres://lldap?host=/var/run/postgresql";
          ldap_port = cfg.ports.ldap;
          ldap_base_dn = "dc=f1nn,dc=space";
          ldap_user_pass_file = config.sops.secrets."${config.networking.hostName}/lldap/admin-password".path;
          force_ldap_user_pass_reset = "always";
          jwt_secret_file = config.sops.secrets."${config.networking.hostName}/lldap/jwt-secret".path;
        };
        environment = {
          LLDAP_KEY_SEED_FILE = config.sops.secrets."${config.networking.hostName}/lldap/key-seed".path;
        };
      };
    };

    custom.services = {
      caddy.hosts = {
        lldap = {
          subdomain = "ldap";
          target = ":${toString cfg.ports.http}";
        };
      };
      postgresql.users = [ "lldap" ];
    };

    sops.secrets = {
      "${config.networking.hostName}/lldap/admin-password".owner = "lldap";
      "${config.networking.hostName}/lldap/jwt-secret".owner = "lldap";
      "${config.networking.hostName}/lldap/key-seed".owner = "lldap";
    };
  };
}
