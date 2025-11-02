{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.jellyfin;
  mediaDir = config.custom.system.media.baseDir;
in
{
  options.custom.services.jellyfin = {
    enable = custom.enableOption;

    subdomain = mkOption {
      type = types.str;
      default = "media";
    };

    id = mkOption {
      type = types.str;
    };

    # useless right now, in preparation for declarative config in the future
    libraries = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            id = mkOption {
              type = types.str;
            };
            type = mkOption {
              type = types.enum [
                "movies"
                "tvshows"
              ];
            };
            path = mkOption {
              type = types.str;
            };
          };
        }
      );
      default = { };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      { assertion = config.custom.system.media.enable; }
    ];

    users.users.jellyfin.extraGroups = [
      "media"
      "render"
      "video"
    ];

    services = {
      jellyfin = {
        enable = true;
      };
    };

    systemd.tmpfiles.rules = mapAttrsToList (
      name: l: "d ${mediaDir}/${l.path} 0770 nobody media - -"
    ) cfg.libraries;

    custom = {
      services.caddy.hosts = {
        jellyfin.target = ":8096";
      };

      system.persistence.config = {
        directories = [
          {
            directory = "/var/lib/jellyfin";
            user = "jellyfin";
            group = "jellyfin";
            mode = "0700";
          }
          {
            directory = "/var/cache/jellyfin";
            user = "jellyfin";
            group = "jellyfin";
            mode = "0700";
          }
        ];
      };

      services.restic = {
        paths = [ "/var/lib/jellyfin" ];
        exclude = [
          "/var/lib/jellyfin/metadata"
        ];
      };
    };
  };
}
