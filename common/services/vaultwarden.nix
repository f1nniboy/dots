{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.vaultwarden;
  port = 8222;
in
{
  options.custom.services.vaultwarden = {
    enable = mkEnableOption "Rust version of the Bitwarden password manager";
  };

  config = mkIf cfg.enable {
    custom.services = {
      postgresql.users = [ "vaultwarden" ];
    };

    users.users.vaultwarden = {
      extraGroups = [ "postgres" ];
    };

    services.vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      config = {
        DATABASE_URL = "postgresql://vaultwarden:@/vaultwarden";
        _ENABLE_SMTP = "false";
        ROCKET_PORT = port;
      };
    };

    custom.services.caddy.hosts = {
      vaultwarden = {
        subdomain = "vault";
        target = ":${toString port}";
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [ "/var/lib/vaultwarden" ];
    };
  };
}
