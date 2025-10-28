{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.vaultwarden;
in
{
  options.custom.services.vaultwarden = {
    enable = custom.enableOption;

    port = mkOption {
      type = types.port;
      default = 8222;
    };
  };

  config = mkIf cfg.enable {
    users.users.vaultwarden = {
      extraGroups = [ "postgres" ];
    };

    services.vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      config = {
        DATABASE_URL = "postgresql://vaultwarden:@/vaultwarden";
        _ENABLE_SMTP = "false";
        ROCKET_PORT = cfg.port;
      };
    };

    custom = {
      services = {
        caddy.hosts = {
          vaultwarden = {
            subdomain = "vault";
            target = ":${toString cfg.port}";
          };
        };
        postgresql.users = [ "vaultwarden" ];
      };

      system.persistence.config = {
        directories = [ "/var/lib/vaultwarden" ];
      };
    };
  };
}
