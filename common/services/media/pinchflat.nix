{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.pinchflat;
in
{
  options.custom.services.pinchflat = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    users.users.pinchflat = {
      group = mkForce "media";
    };

    systemd = {
      services.pinchflat = {
        serviceConfig = {
          Group = mkForce "media";
        };
      };

      tmpfiles.rules = [
        "d ${config.custom.media.baseDir}/library/archive 0770 pinchflat media - -"
      ];
    };

    services.pinchflat = {
      enable = true;
      selfhosted = true;
      mediaDir = "${config.custom.media.baseDir}/library/archive";
    };

    custom = {
      services.caddy.hosts = {
        pinchflat = {
          subdomain = "archive.media";
          target = ":${toString config.services.pinchflat.port}";
          import = [ "auth" ];
        };
      };

      system.persistence.config = {
        directories = [
          {
            directory = "/var/lib/pinchflat";
            user = "pinchflat";
            group = "media";
            mode = "0700";
          }
        ];
      };

      services.restic = {
        paths = [
          "/var/lib/pinchflat"
        ];
        exclude = [
          "/var/lib/pinchflat/logs"
          "/var/lib/pinchflat/tmp"
        ];
      };
    };
  };
}
