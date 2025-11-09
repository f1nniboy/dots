{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.immich;
  mediaDir = "/fun/media/gallery";
in
{
  options.custom.services.immich = {
    enable = custom.enableOption;

    forOidc = mkOption {
      type = types.bool;
      default = cfg.enable;
    };

    subdomain = mkOption {
      type = types.str;
      default = "photo";
    };
  };

  config = mkMerge [
    (mkIf cfg.forOidc {
      custom.services.authelia.clients.immich = {
        name = "Immich";
        id = "immich";
        requirePkce = true;
        redirectUris = [
          "app.immich:///oauth-callback"
          "https://${custom.mkServiceDomain config "immich"}/auth/login"
          "https://${custom.mkServiceDomain config "immich"}/user-settings"
        ];
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
          content = import ./config.nix {
            inherit lib config;
          };
          owner = "immich";
        };
      };

      custom = {
        services = {
          caddy.hosts = {
            immich.target = ":${toString config.services.immich.port}";
          };
          authelia.clients.immich.makeSecrets = true;
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
