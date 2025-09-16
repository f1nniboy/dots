{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.ssh;
in
{
  options.custom.system.ssh = {
    authorizedKeys = mkOption {
      type = types.listOf types.str;
    };
  };

  config = {
    users.mutableUsers = false;

    users.users.${config.custom.system.user.name} = {
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };
  };
}
