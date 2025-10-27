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
        inherit (config.sops) secrets;

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
          repositoryFile = secrets."${config.networking.hostName}/restic/borgbase/url".path;
          passwordFile = secrets."${config.networking.hostName}/restic/borgbase/password".path;
          timerConfig.OnCalendar = cfg.frequency;
          inherit (cfg) paths exclude;
          inherit pruneOpts;
        };
      };

    sops.secrets = mkMerge [
      (mkIf cfg.repos.borgbase {
        "${config.networking.hostName}/restic/borgbase/url" = { };
        "${config.networking.hostName}/restic/borgbase/password" = { };
      })
    ];
  };
}
