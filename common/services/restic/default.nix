{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.restic;
in
{
  options.custom.services.restic = {
    enable = custom.enableOption;
    repos = mkOption {
      default = {
        borgbase = true;
      };
      type = types.submodule {
        options = {
          borgbase = custom.enableOption;
        };
      };
    };
    paths = mkOption {
      type = types.listOf types.str;
    };
    exclude = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    frequency = mkOption {
      type = types.str;
      description = "frequency of backups, in systemd calendar time format";
      default = "daily";
    };
  };

  config = mkIf cfg.enable {
    services.restic.backups =
      let
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 3"
          "--keep-yearly 1"
        ];
      in
      {
        borgbase = mkIf cfg.repos.borgbase {
          initialize = true;
          repositoryFile = custom.mkSecretPath config "restic/borgbase/url" "root";
          passwordFile = custom.mkSecretPath config "restic/borgbase/password" "root";
          timerConfig.OnCalendar = cfg.frequency;
          inherit (cfg) paths exclude;
          inherit pruneOpts;
        };
      };

    custom.system = {
      sops.secrets = mkMerge [
        (mkIf cfg.repos.borgbase [
          {
            path = "restic/borgbase/url";
          }
          {
            path = "restic/borgbase/password";
          }
        ])
      ];
    };
  };
}
