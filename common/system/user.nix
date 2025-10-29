{
  config,
  lib,
  vars,
  ...
}:
with lib;
let
  cfg = config.custom.system.user;
in
{
  options.custom.system.user = {
    name = mkOption {
      type = types.str;
      default = "me";
    };
    fullName = mkOption {
      type = types.str;
      default = vars.user.fullName;
    };
    email = mkOption {
      type = types.str;
      default = vars.user.email;
    };
    sshPublicKey = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = {
    sops.secrets = {
      "common/user/hashed-password".neededForUsers = true;
    };

    users = {
      mutableUsers = false;

      users.${cfg.name} = {
        description = cfg.fullName;
        isNormalUser = true;
        extraGroups = cfg.extraGroups ++ [
          "wheel"
        ];
        hashedPasswordFile = config.sops.secrets."common/user/hashed-password".path;
      };
    };
  };
}
