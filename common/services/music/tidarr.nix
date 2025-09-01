{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.tidarr;
  port = 8484;
in
{
  options.custom.services.tidarr = {
    enable = mkEnableOption "Tidarr music downloader";
  };

  config = mkIf cfg.enable {
    users = {
      users.tidarr = {
        isSystemUser = true;
        group = "media";
        uid = 1103;
      };
    };

    virtualisation.oci-containers.containers = {
      "tidarr" = {
        image = "cstaelen/tidarr:latest";
        ports = [
          "${toString port}:${toString port}"
        ];
        volumes = [
          "/var/lib/tidarr:/home/app/standalone/shared"
          "/fun/media/htpc/downloads/tidal/incomplete:/home/app/standalone/download/incomplete"
          "/fun/media/htpc/library/music:/home/app/standalone/download/albums"
          "/fun/media/htpc/library/music:/home/app/standalone/download/tracks"
        ];
        environment = {
          "PUID" = toString config.users.users.tidarr.uid;
          "PGID" = toString config.users.groups.media.gid;
        };
      };
    };

    custom.services.caddy.hosts = {
      tidarr = {
        subdomain = "tidal.media";
        target = ":${toString port}";
        import = [ "auth" ];
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/tidarr";
          user = "tidarr";
          group = "media";
          mode = "0700";
        }
      ];
    };
  };
}
