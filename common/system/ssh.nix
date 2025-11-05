{
  config,
  lib,
  vars,
  ...
}:
with lib;
let
  cfg = config.custom.system.ssh;
in
{
  options.custom.system.ssh = {
    enable = custom.enableOption;
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = vars.ssh.authorizedKeys;
    };
  };

  config = mkIf cfg.enable {
    users.users.${config.custom.system.user.name} = {
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };
  };
}
