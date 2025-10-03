{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.immich;
  mediaDir = "/fun/media/gallery";
in
{
  options.custom.services.immich = {
    enable = mkEnableOption "Immich photo library";
  };

  config = mkIf cfg.enable {
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

    custom.services = {
      caddy.hosts = {
        immich = {
          subdomain = "photo";
          target = ":${toString config.services.immich.port}";
        };
      };
      postgresql.users = [ "immich" ];
      redis.servers = [ "immich" ];
    };

    sops = {
      templates.immich-config = {
        content = import ./config/immich.nix {
          inherit config;
        };
        owner = "immich";
      };
      secrets = {
        "authelia-${config.networking.hostName}/oidc/immich/id" = {
          key = "${config.networking.hostName}/oidc/immich/id";
          owner = "authelia-main";
        };
        "${config.networking.hostName}/oidc/immich/id".owner = "immich";

        "${config.networking.hostName}/oidc/immich/secret".owner = "immich";
        "${config.networking.hostName}/oidc/immich/secret-hash".owner = "authelia-main";
      };
    };

    environment.persistence."/nix/persist" = {
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

    systemd.tmpfiles.rules = [
      "d ${mediaDir} 0700 immich immich - -"
    ];

    custom.services.restic = {
      paths = [
        mediaDir
      ];
      exclude = [
        "/fun/media/gallery/backups" # we're already backing up the db
        "/fun/media/gallery/thumbs"  # can be re-generated afterwards
        "/fun/media/gallery/upload"  # only used for uploads
      ];
    };
  };
}
