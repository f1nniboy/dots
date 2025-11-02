{
  config,
  lib,
  vars,
  ...
}:
with lib;
let
  cfg = config.custom.services.muse;
in
{
  options.custom.services.muse = {
    enable = custom.enableOption;
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
        image = "dovah/muse:${vars.docker.images.muse}";
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
          DISCORD_TOKEN=${custom.mkSecretPlaceholder config "muse/discord-token" "muse"}
          YOUTUBE_API_KEY=${custom.mkSecretPlaceholder config "muse/youtube-api-key" "muse"}
          SPOTIFY_CLIENT_ID=${custom.mkSecretPlaceholder config "muse/spotify/id" "muse"}
          SPOTIFY_CLIENT_SECRET=${custom.mkSecretPlaceholder config "muse/spotify/secret" "muse"}
        '';
        owner = "muse";
      };
    };

    custom.system = {
      sops.secrets = [
        {
          path = "muse/discord-token";
          owner = "muse";
        }
        {
          path = "muse/youtube-api-key";
          owner = "muse";
        }
        {
          path = "muse/spotify/id";
          owner = "muse";
        }
        {
          path = "muse/spotify/secret";
          owner = "muse";
        }

      ];
      persistence.config = {
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
  };
}
