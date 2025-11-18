{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.immich;
  mediaDir = "/fun/media/gallery";

  configContent = builtins.toJSON (
    import ./config.nix {
      inherit lib config;
    }
  );

  serviceDomain = custom.mkServiceDomain config "immich";
in
{
  options.custom.services.immich = {
    enable = custom.enableOption;

    forAuth = mkOption {
      type = types.bool;
      default = cfg.enable;
    };
  };

  config = mkMerge [
    (mkIf cfg.forAuth {
      custom.services.authelia.clients.immich = {
        name = "Immich";
        redirectUris = [
          "app.immich:///oauth-callback"
          "https://${serviceDomain}/auth/login"
          "https://${serviceDomain}/user-settings"
        ];
        makeSecrets = cfg.enable;
      };
    })
    (mkIf cfg.enable {
      users.users.immich = {
        home = "/var/lib/immich";
        createHome = true;
        extraGroups = [
          "postgres"
          "redis-immich"
        ];
      };

      services.immich = {
        enable = true;
        mediaLocation = mediaDir;
        database = {
          createDB = false;
        };
        redis = {
          # we already created an instance ourselves
          enable = false;
        };
        environment = {
          IMMICH_HOST = mkForce "127.0.0.1";
          IMMICH_CONFIG_FILE = config.sops.templates."immich-config".path;
        };
      };

      systemd.tmpfiles.rules = [
        "d ${mediaDir} 0700 immich immich - -"
      ];

      sops = {
        templates.immich-config = {
          content = configContent;
          owner = "immich";
          restartUnits = [
            "immich-server.service"
            "immich-machine-learning.service"
          ];
        };
      };

      custom = {
        services = {
          caddy.hosts = {
            immich.target = ":${toString config.services.immich.port}";
          };
          postgresql.users = [ "immich" ];
          redis.servers = [ "immich" ];
          restic = {
            paths = [ mediaDir ];
            exclude = [
              "${mediaDir}/backups" # we're already backing up the db
              "${mediaDir}/thumbs" # can be re-generated afterwards
              "${mediaDir}/upload" # only used for uploads
            ];
          };
        };

        system.persistence.config = {
          directories = [
            {
              directory = "/var/lib/immich";
              user = "immich";
              group = "immich";
              mode = "0700";
            }
            {
              directory = "/var/cache/immich";
              user = "immich";
              group = "immich";
              mode = "0700";
            }
          ];
        };
      };
    })
  ];
}
