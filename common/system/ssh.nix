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

    users.users.${cfg.name} = {
      openssh.authorizedKeys.keys = config.custom.system.ssh.authorizedKeys;
    };
  };
}
