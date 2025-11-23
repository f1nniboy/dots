{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.restic;
in
{
  options.custom.services.restic = {
    enable = custom.enableOption;
    repos = mkOption {
      type = types.submodule {
        options =
          let
            mkRepoOption =
              def:
              mkOption {
                type = types.bool;
                default = def;
              };
          in
          {
            borgbase = mkRepoOption true;
          };
      };
      default = { };
    };
    paths = mkOption {
      type = types.listOf types.str;
      default = [ ];
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

        mkRepo =
          name: enabled:
          if enabled then
            mkIf cfg.repos."${name}" {
              initialize = true;
              repositoryFile = custom.mkSecretPath config "restic/${name}/url" "root";
              passwordFile = custom.mkSecretPath config "restic/${name}/password" "root";
              timerConfig.OnCalendar = cfg.frequency;
              inherit (cfg) paths exclude;
              inherit pruneOpts;
            }
          else
            { };
      in
      mapAttrs mkRepo cfg.repos;

    custom.system = {
      sops.secrets =
        let
          mkRepoSecrets =
            name: enabled:
            if enabled then
              [
                { path = "restic/${name}/url"; }
                { path = "restic/${name}/password"; }
              ]
            else
              [ ];

          secrets = mapAttrsToList mkRepoSecrets cfg.repos;
        in
        mkMerge secrets;
    };
  };
}
