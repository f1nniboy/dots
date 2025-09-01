{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.postgresql;
in
{
  options.custom.services.postgresql = {
    enable = mkEnableOption "PostgreSQL database";

    users = mkOption {
      type = types.listOf types.str;
      description = "List of PostgreSQL users & databases to create";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;

      settings = {
        unix_socket_permissions = "0660";
        listen_addresses = lib.mkForce "";
      };

      # ensure databases are created
      ensureDatabases = cfg.users;

      # create users with database ownership
      ensureUsers = map (user: {
        name = user;
        ensureDBOwnership = true;
      }) cfg.users;

      authentication = pkgs.lib.mkOverride 10 ''
                # TYPE  DATABASE  USER      ADDRESS   		METHOD
                local   all       all                 		peer
      '';
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/postgresql";
          user = "postgres";
          group = "postgres";
          mode = "0700";
        }
      ];
    };

    custom.services.restic.paths = [
      "/var/lib/postgresql"
    ];
  };
}
