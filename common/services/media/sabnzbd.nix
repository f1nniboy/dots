{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.sabnzbd;
in
{
  options.custom.services.sabnzbd = {
    enable = mkEnableOption "SABnzbd download client";
  };

  config = mkIf cfg.enable {
    services.sabnzbd = {
      enable = true;
      group = "media";
    };

    custom.services.caddy.hosts = {
      sabnzbd = {
        subdomain = "dl.media";
        target = ":8080";
        import = [ "auth" ];
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/sabnzbd";
          user = "sabnzbd";
          group = "media";
          mode = "0700";
        }
      ];
    };

    custom.services.restic.paths = [
      "/var/lib/sabnzbd"
    ];
  };
}
