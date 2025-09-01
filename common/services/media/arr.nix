{
  inputs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.arr;
  gitPkgs = import inputs.nixpkgs-git { system = "x86_64-linux"; };
in
{

  options.custom.services.arr = {
    enable = mkEnableOption "*arr media stack";
  };

  config = mkIf cfg.enable {
    users = {
      users.prowlarr = {
        isSystemUser = true;
        group = "media";
      };
    };

    services = {
      prowlarr = {
        enable = true;
      };
      radarr = {
        package = gitPkgs.radarr;
        enable = true;
        group = "media";
      };
      sonarr = {
        enable = true;
        group = "media";
      };
      lidarr = {
        enable = false; # TRUE
        group = "media";
        package = gitPkgs.lidarr.overrideAttrs (
          old:
          let
            os = "linux";
            arch = "x64";
            branch = "plugins";
          in
          {
            inherit version;
            src = gitPkgs.fetchurl {
              url = "https://lidarr.servarr.com/v1/update/${branch}/updatefile?os=${os}&runtime=netcore&arch=${arch}";
              name = "lidarr-netcore-${os}-${arch}.tar.gz";
              sha256 = "sha256-g/Nmi4X/qlqqjY/zoG90iyP5Y5fse6Akr8exG5Spf08=";
            };
          }
        );
      };
      recyclarr = {
        enable = true;
        group = "media";
        configuration = import ../config/recyclarr.nix {
          inherit config;
        };
      };
    };

    systemd.services = {
      prowlarr = {
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "prowlarr";
          Group = "media";
        };
        environment = {
          PROWLARR__AUTH__REQUIRED = "True";
          PROWLARR__AUTH__METHOD = "External";
        };
      };
      radarr = {
        environment = {
          RADARR__AUTH__REQUIRED = "True";
          RADARR__AUTH__METHOD = "External";
        };
      };
      sonarr = {
        environment = {
          SONARR__AUTH__REQUIRED = "True";
          SONARR__AUTH__METHOD = "External";
        };
      };
      #lidarr = {
      #  path = [ pkgs.ffmpeg ];
      #  environment = {
      #    LIDARR__AUTH__REQUIRED = "True";
      #    LIDARR__AUTH__METHOD = "External";
      #  };
      #};
      recyclarr.serviceConfig.LoadCredential = [
        "radarr_api-key:${config.sops.secrets."recyclarr-${config.networking.hostName}/radarr/api-key".path}"
        "sonarr_api-key:${config.sops.secrets."recyclarr-${config.networking.hostName}/sonarr/api-key".path}"
      ];
    };

    custom.services = {
      caddy.hosts = {
        prowlarr = {
          subdomain = "idx.media";
          target = ":${toString config.services.prowlarr.settings.server.port}";
          import = [ "auth" ];
        };
        radarr = {
          subdomain = "mov.media";
          target = ":${toString config.services.radarr.settings.server.port}";
          import = [ "auth" ];
        };
        sonarr = {
          subdomain = "tv.media";
          target = ":${toString config.services.sonarr.settings.server.port}";
          import = [ "auth" ];
        };
        lidarr = {
          subdomain = "music.media";
          target = ":${toString config.services.lidarr.settings.server.port}";
          import = [ "auth" ];
        };
      };
      authelia.rules = [
        # required for nzb360 mobile app
        {
          domain = "*.media.${config.custom.services.caddy.domain}";
          policy = "bypass";
          resources = [ "/api.*" ];
        }
      ];
    };

    sops.secrets = {
      "recyclarr-${config.networking.hostName}/radarr/api-key" = {
        key = "${config.networking.hostName}/radarr/api-key";
        owner = "recyclarr";
      };
      "recyclarr-${config.networking.hostName}/sonarr/api-key" = {
        key = "${config.networking.hostName}/sonarr/api-key";
        owner = "authelia-main";
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/prowlarr";
          user = "prowlarr";
          group = "media";
          mode = "0700";
        }
        {
          directory = "/var/lib/radarr";
          user = "radarr";
          group = "media";
          mode = "0700";
        }
        {
          directory = "/var/lib/sonarr";
          user = "sonarr";
          group = "media";
          mode = "0700";
        }
        {
          directory = "/var/lib/lidarr";
          user = "lidarr";
          group = "media";
          mode = "0700";
        }
      ];
    };

    custom.services.restic.paths = [
      "/var/lib/prowlarr"
      "/var/lib/radarr"
      "/var/lib/sonarr"
      "/var/lib/lidarr"
    ];
  };
}
