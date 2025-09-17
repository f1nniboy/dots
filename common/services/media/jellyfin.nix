{
  config,
  lib,
  pkgs,
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
    enable = mkEnableOption "Jellyfin media server";
    id = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.jellyfin-ffmpeg ];

    users.users.jellyfin.extraGroups = [
      "media"
      "render"
      "video"
    ];

    services.declarative-jellyfin = {
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
            pathInfos = [ "/fun/media/htpc/library/movies" ];
          }
          baseLibrarySettings
        ];
        Serien = mkMerge [
          {
            enabled = true;
            contentType = "tvshows";
            pathInfos = [ "/fun/media/htpc/library/shows" ];
          }
          baseLibrarySettings
        ];
      };

      users = {
        Finn = {
          mutable = false;
          hashedPasswordFile = config.sops.secrets."${config.networking.hostName}/jellyfin/users/Finn".path;
          permissions = {
            isAdministrator = true;
          };
        };
      };

      apikeys = {
        jellyseerr = {
          keyPath = config.sops.secrets."jellyfin-${config.networking.hostName}/jellyfin/api-keys/jellyseerr".path;
        };
        multi-scrobbler = {
          keyPath = config.sops.secrets."jellyfin-${config.networking.hostName}/jellyfin/api-keys/multi-scrobbler".path;
        };
      };
    };

    services.samba = {
      settings = {
        "library" = {
          "path" = "/fun/media/htpc/library";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "force user" = "jellyfin";
          "force group" = "media";
        };
      };
    };

    custom.services.caddy.hosts = {
      jellyfin = {
        subdomain = "media";
        target = ":8096";
      };
    };

    environment.persistence."/nix/persist" = {
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

    sops.secrets = {
      "${config.networking.hostName}/jellyfin/server-id".owner = "jellyfin";
      "${config.networking.hostName}/jellyfin/users/Finn".owner = "jellyfin";

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

    custom.services.restic = {
      paths = [ "/var/lib/jellyfin" ];
      exclude = [
        "/var/lib/jellyfin/metadata"
      ];
    };
  };
}
