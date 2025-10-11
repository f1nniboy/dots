{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.user;
in
{
  options.custom.system.user = {
    name = mkOption { type = types.str; };
    fullName = mkOption { type = types.str; };
    email = mkOption { type = types.str; };
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
    users.mutableUsers = false;

    users.users.${cfg.name} = {
      description = cfg.fullName;
      isNormalUser = true;
      extraGroups = cfg.extraGroups ++ [
        "wheel"
      ];
      hashedPasswordFile = config.sops.secrets."common/user/hashed-password".path;
    };
  };
}
