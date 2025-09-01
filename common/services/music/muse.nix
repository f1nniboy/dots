{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.muse;
in
{
  options.custom.services.muse = {
    enable = mkEnableOption "Muse Discord bot";
  };

  config = mkIf cfg.enable {
    users = {
      users.muse = {
        isSystemUser = true;
        group = "muse";
        uid = 1102;
      };
      groups.muse = {
        gid = 1102;
      };
    };

    virtualisation.oci-containers.containers = {
      "muse" = {
        image = "dovah/muse:latest";
        user = "${toString config.users.users.muse.uid}:${toString config.users.groups.muse.gid}";
        volumes = [
          "/var/lib/muse:/data:rw"
        ];
        environmentFiles = [
          config.sops.templates.muse-env.path
        ];
      };
    };

    sops = {
      templates.muse-env = {
        content = ''
          DISCORD_TOKEN=${config.sops.placeholder."${config.networking.hostName}/muse/discord-token"}
          YOUTUBE_API_KEY=${config.sops.placeholder."${config.networking.hostName}/muse/youtube-api-key"}
          SPOTIFY_CLIENT_ID=${config.sops.placeholder."${config.networking.hostName}/muse/spotify/id"}
          SPOTIFY_CLIENT_SECRET=${config.sops.placeholder."${config.networking.hostName}/muse/spotify/secret"}
        '';
        owner = "muse";
      };
      secrets = {
        "${config.networking.hostName}/muse/discord-token".owner = "muse";
        "${config.networking.hostName}/muse/youtube-api-key".owner = "muse";
        "${config.networking.hostName}/muse/spotify/id".owner = "muse";
        "${config.networking.hostName}/muse/spotify/secret".owner = "muse";
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/muse";
          user = "muse";
          group = "muse";
          mode = "0700";
        }
      ];
    };
  };
}
