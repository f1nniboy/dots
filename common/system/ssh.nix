{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.ssh;
in
{
  options.custom.system.ssh = {
    enable = custom.enableOption;
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = config.custom.cfg.ssh.authorizedKeys;
    };
  };

  config = mkIf cfg.enable {
    users.users.${config.custom.system.user.name} = {
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };
  };
}
