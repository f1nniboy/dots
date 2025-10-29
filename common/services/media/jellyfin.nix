{
  inputs,
  config,
  lib,
  pkgs,
  vars,
  ...
}:
with lib;
let
  cfg = config.custom.services.jellyfin;

  baseLibrarySettings = {
    preferredMetadataLanguage = "de";

    enableChapterImageExtraction = true;
    extractChapterImagesDuringLibraryScan = true;
    enableTrickplayImageExtraction = true;
    extractTrickplayImagesDuringLibraryScan = true;
  };
in
{
  options.custom.services.jellyfin = {
    enable = custom.enableOption;
    id = mkOption {
      type = types.str;
    };
  };

  imports = [
    inputs.declarative-jellyfin.nixosModules.default
  ];

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.jellyfin-ffmpeg ];

    users.users.jellyfin.extraGroups = [
      "media"
      "render"
      "video"
    ];

    services = {
      declarative-jellyfin = {
        enable = true;
        backups = false;

        serverId = cfg.id;

        system = {
          serverName = "Jelly";
          UICulture = "de";
          preferredMetadataLanguage = "de";
          metadataCountryCode = "DE";
          trickplayOptions = {
            enableHwAcceleration = true;
            enableHwEncoding = true;
          };
        };

        branding = {
          customCss = ''
            @import url("https://cdn.jsdelivr.net/gh/lscambo13/ElegantFin@main/Theme/ElegantFin-jellyfin-theme-build-latest-minified.css");
          '';
        };

        encoding = {
          hardwareAccelerationType = "qsv";
          enableVppTonemapping = true;
          enableThrottling = true;
          enableSegmentDeletion = true;
        };

        libraries = {
          Filme = mkMerge [
            {
              enabled = true;
              contentType = "movies";
              pathInfos = [ "${config.custom.media.baseDir}/library/movies" ];
            }
            baseLibrarySettings
          ];
          Serien = mkMerge [
            {
              enabled = true;
              contentType = "tvshows";
              pathInfos = [ "${config.custom.media.baseDir}/library/shows" ];
            }
            baseLibrarySettings
          ];
        };

        users = {
          ${vars.user.fullName} = {
            mutable = false;
            hashedPasswordFile =
              config.sops.secrets."${config.networking.hostName}/jellyfin/users/${vars.user.fullName}".path;
            permissions = {
              isAdministrator = true;
            };
          };
        };

        apikeys = {
          jellyseerr = {
            keyPath =
              config.sops.secrets."jellyfin-${config.networking.hostName}/jellyfin/api-keys/jellyseerr".path;
          };
          multi-scrobbler = {
            keyPath =
              config.sops.secrets."jellyfin-${config.networking.hostName}/jellyfin/api-keys/multi-scrobbler".path;
          };
        };
      };

      samba = {
        settings = {
          "library" = {
            "path" = "${config.custom.media.baseDir}/library";
            "browseable" = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "force user" = "jellyfin";
            "force group" = "media";
          };
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${config.custom.media.baseDir}/library/movies 0770 nobody media - -"
      "d ${config.custom.media.baseDir}/library/shows  0770 nobody media - -"
    ];

    sops.secrets = {
      "${config.networking.hostName}/jellyfin/server-id".owner = "jellyfin";
      "${config.networking.hostName}/jellyfin/users/${vars.user.fullName}".owner = "jellyfin";

      # api keys
      "jellyfin-${config.networking.hostName}/jellyfin/api-keys/jellyseerr" = {
        key = "${config.networking.hostName}/jellyfin/api-keys/jellyseerr";
        owner = "jellyfin";
      };
      "jellyfin-${config.networking.hostName}/jellyfin/api-keys/multi-scrobbler" = {
        key = "${config.networking.hostName}/jellyfin/api-keys/multi-scrobbler";
        owner = "jellyfin";
      };
    };

    custom = {
      services.caddy.hosts = {
        jellyfin = {
          subdomain = "media";
          target = ":8096";
        };
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
