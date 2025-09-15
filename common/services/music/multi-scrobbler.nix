{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.multi-scrobbler;
in
{
  options.custom.services.multi-scrobbler = {
    enable = mkEnableOption "Scrobble plays from multiple sources to multiple clients";

    port = mkOption {
      type = types.port;
      default = 9078;
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.multi-scrobbler = {
        isSystemUser = true;
        group = "multi-scrobbler";
        uid = 1104;
      };
      groups.multi-scrobbler = {
        gid = 1104;
      };
    };

    virtualisation.oci-containers.containers = {
      "multi-scrobbler" = {
        image = "foxxmd/multi-scrobbler:latest";
        volumes = [
          "/var/lib/multi-scrobbler:/config"
          "/var/lib/multi-scrobbler/config.json:/config/config.json"
        ];
        environment = {
          "TZ" = config.time.timeZone;
          "PUID" = toString config.users.users.multi-scrobbler.uid;
          "PGID" = toString config.users.groups.multi-scrobbler.gid;
        };
        extraOptions = [ "--network=host" ];
      };
    };

    custom.services.caddy.hosts = {
      multi-scrobbler = {
        subdomain = "scrobbler";
        target = ":${toString cfg.port}";
        import = [ "auth" ];
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/multi-scrobbler";
          user = "multi-scrobbler";
          group = "multi-scrobbler";
          mode = "0700";
        }
      ];
    };

    sops = {
      templates.multi-scrobbler-config = {
        path = "/var/lib/multi-scrobbler/config.json";
        content = import ../config/multi-scrobbler.nix {
          inherit config;
        };
        owner = "multi-scrobbler";
        mode = "0600";
      };
      secrets = {
        "${config.networking.hostName}/multi-scrobbler/sources/jellyfin/user".owner = "multi-scrobbler";
        "multi-scrobbler-${config.networking.hostName}/jellyfin/api-keys/multi-scrobbler" = {
          key = "${config.networking.hostName}/jellyfin/api-keys/multi-scrobbler";
          owner = "multi-scrobbler";
        };

        "${config.networking.hostName}/multi-scrobbler/sources/spotify/client-id".owner = "multi-scrobbler";
        "${config.networking.hostName}/multi-scrobbler/sources/spotify/client-secret".owner = "multi-scrobbler";

        "${config.networking.hostName}/multi-scrobbler/clients/listenbrainz/token".owner = "multi-scrobbler";
        "${config.networking.hostName}/multi-scrobbler/clients/listenbrainz/username".owner = "multi-scrobbler";

        "${config.networking.hostName}/multi-scrobbler/clients/lastfm/api-key".owner = "multi-scrobbler";
        "${config.networking.hostName}/multi-scrobbler/clients/lastfm/secret".owner = "multi-scrobbler";
      };
    };
  };
}
