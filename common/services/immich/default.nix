{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.immich;
  mediaDir = "/fun/media/gallery";
in
{
  options.custom.services.immich = {
    enable = custom.enableOption;

    subdomain = mkOption {
      type = types.str;
      default = "photo";
    };
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
        authelia.clients = [
          {
            name = "Immich";
            id = "immich";
            policy = "one_factor";
            requirePkce = true;
            scopes = [
              "openid"
              "profile"
              "email"
            ];
            redirectUris = [
              "app.immich:///oauth-callback"
              "https://${custom.mkServiceDomain config "immich"}/auth/login"
              "https://${custom.mkServiceDomain config "immich"}/user-settings"
            ];
            public = false;
            responseTypes = [ "code" ];
            grantTypes = [ "authorization_code" ];
            accessTokenAlg = "none";
            userinfoAlg = "none";
            tokenAuthMethod = "client_secret_basic";
          }
        ];
        postgresql.users = [ "immich" ];
        redis.servers = [ "immich" ];
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

      services.restic = {
        paths = [ mediaDir ];
        exclude = [
          "${mediaDir}/backups" # we're already backing up the db
          "${mediaDir}/thumbs" # can be re-generated afterwards
          "${mediaDir}/upload" # only used for uploads
        ];
      };
    };
  };
}
