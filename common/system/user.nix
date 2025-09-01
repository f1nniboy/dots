{ config, lib, ... }:
with lib;
let
  cfg = config.custom.user;
in
{
  options.custom.user = {
    name = mkOption { type = types.str; };
    fullName = mkOption { type = types.str; };
    email = mkOption { type = types.str; };
    sshPublicKey = mkOption { type = types.str; };
  };

  config = {
    users.mutableUsers = false;

    users.users.${cfg.name} = {
      description = cfg.fullName;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [ cfg.sshPublicKey ];
      hashedPasswordFile = config.sops.secrets."common/user/hashed-password".path;
    };
  };
}
