{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.fileflows;
in
{
  options.custom.services.fileflows = {
    enable = mkEnableOption "FileFlows media post-processing";

    port = mkOption {
      type = types.port;
      default = 5000;
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.fileflows = {
        isSystemUser = true;
        uid = 1500;
        group = "media";
        extraGroups = [ "render" ];
      };
    };

    virtualisation.oci-containers.containers."fileflows" = {
      image = "revenz/fileflows:latest";
      ports = [ "127.0.0.1:${toString cfg.port}:5000" ];
      environment = {
        "PGID" = "${toString config.users.groups.media.gid}";
        "PUID" = "${toString config.users.users.fileflows.uid}";
        "TZ" = config.time.timeZone;
      };
      volumes = [
        "/fun/media/htpc:/media:rw"
        "/var/lib/fileflows:/app/Data:rw"
        "/fun/media/htpc/tmp:/temp:rw"
      ];
      extraOptions = [
        "--device=/dev/dri:/dev/dri:rwm"
      ];
    };

    custom.services.caddy.hosts = {
      fileflows = {
        subdomain = "flows.media";
        target = ":${toString cfg.port}";
        import = [ "auth" ];
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/fileflows";
          user = "fileflows";
          group = "media";
          mode = "0700";
        }
      ];
    };

    custom.services.restic.paths = [
      "/var/lib/fileflows"
    ];
  };
}
