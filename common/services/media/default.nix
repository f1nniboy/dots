{ config, lib, ... }:
with lib;
let
  cfg = config.custom.media;
in
{
  options.custom.media = {
    enable = custom.enableOption;

    baseDir = mkOption {
      type = types.str;
      default = "/fun/media/htpc";
    };
  };

  imports = [
    ./arr.nix
    ./fileflows.nix
    ./jellyfin.nix
    ./jellyseerr.nix
    ./pinchflat.nix
    ./sabnzbd.nix
  ];

  config = mkIf cfg.enable {
    users = {
      users.media = {
        group = "media";
        isSystemUser = true;
      };
      groups.media = {
        gid = 981;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.baseDir} 0770 nobody media - -"
    ];
  };
}
