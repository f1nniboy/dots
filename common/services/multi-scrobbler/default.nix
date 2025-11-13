{
  config,
  lib,
  vars,
  ...
}:
with lib;
let
  cfg = config.custom.services.multi-scrobbler;

  configContent = builtins.toJSON (
    import ./config.nix {
      inherit lib config;
    }
  );
in
{
  options.custom.services.multi-scrobbler = {
    enable = custom.enableOption;

    subdomain = mkOption {
      type = types.str;
      default = "scrobbler";
    };

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
        image = custom.mkDockerImage vars "foxxmd/multi-scrobbler";
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

    sops = {
      templates.multi-scrobbler-config = {
        path = "/var/lib/multi-scrobbler/config.json";
        content = configContent;
        owner = "multi-scrobbler";
        mode = "0600";
      };
    };

    custom = {
      system = {
        sops.secrets =
          let
            entries = [
              {
                type = "sources";
                name = "spotify";
                secrets = [
                  "client-id"
                  "client-secret"
                ];
              }
              {
                type = "clients";
                name = "listenbrainz";
                secrets = [
                  "token"
                  "username"
                ];
              }
              {
                type = "clients";
                name = "lastfm";
                secrets = [
                  "api-key"
                  "secret"
                ];
              }
            ];
            mkEntrySecrets =
              entry:
              map (secret: {
                path = "multi-scrobbler/${entry.type}/${entry.name}/${secret}";
                owner = "multi-scrobbler";
              }) entry.secrets;
          in
          concatLists (map mkEntrySecrets entries);
        persistence.config = {
          directories = [
            {
              directory = "/var/lib/multi-scrobbler";
              user = "multi-scrobbler";
              group = "multi-scrobbler";
              mode = "0700";
            }
          ];
        };
      };
      services.caddy.hosts = {
        multi-scrobbler = {
          target = ":${toString cfg.port}";
          import = [ "auth" ];
        };
      };
    };
  };
}
