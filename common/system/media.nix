{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.media;
in
{
  options.custom.system.media = {
    enable = custom.enableOption;

    subdomain = mkOption {
      type = types.str;
      default = "media";
    };

    baseDir = mkOption {
      type = types.str;
      default = "/fun/media/htpc";
    };
  };

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
