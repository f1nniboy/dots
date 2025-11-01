{
  config,
  lib,
  vars,
  ...
}:
with lib;
let
  cfg = config.custom.services.fileflows;
in
{
  options.custom.services.fileflows = {
    enable = custom.enableOption;

    subdomain = mkOption {
      type = types.str;
      default = "flows.media";
    };

    port = mkOption {
      type = types.port;
      default = 5000;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      { assertion = config.custom.system.media.enable; }
    ];

    users = {
      users.fileflows = {
        isSystemUser = true;
        uid = 1500;
        group = "media";
        extraGroups = [ "render" ];
      };
    };

    virtualisation.oci-containers.containers."fileflows" = {
      image = "revenz/fileflows:${vars.docker.images.fileflows}";
      ports = [ "127.0.0.1:${toString cfg.port}:5000" ];
      environment = {
        "PGID" = toString config.users.groups.media.gid;
        "PUID" = toString config.users.users.fileflows.uid;
        "TZ" = config.time.timeZone;
      };
      volumes = [
        "${config.custom.system.media.baseDir}:/media:rw"
        "/var/lib/fileflows:/app/Data:rw"
        "${config.custom.system.media.baseDir}/tmp:/temp:rw"
      ];
      extraOptions = [
        "--device=/dev/dri:/dev/dri:rwm"
      ];
    };

    custom = {
      services.caddy.hosts = {
        fileflows = {
          target = ":${toString cfg.port}";
          import = [ "auth" ];
        };
      };

      system.persistence.config = {
        directories = [
          {
            directory = "/var/lib/fileflows";
            user = "fileflows";
            group = "media";
            mode = "0700";
          }
        ];
      };

      services.restic.paths = [
        "/var/lib/fileflows"
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${config.custom.system.media.baseDir}/downloads/converted/movies 0770 fileflows media - -"
      "d ${config.custom.system.media.baseDir}/downloads/converted/shows  0770 fileflows media - -"
    ];
  };
}
