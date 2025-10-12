{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.system.sops;
in
{
  options.custom.system.sops = {
    enable = mkEnableOption "sops secrets";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.sops ];

    sops = {
      defaultSopsFile = ./../../secrets/secrets.yaml;
      age.sshKeyPaths = [ "/nix/secret/initrd/ssh_host_ed25519_key" ];

      secrets = {
        "common/user/hashed-password".neededForUsers = true;
      };

      # ref: https://github.com/Mic92/sops-nix/issues/427
      gnupg.sshKeyPaths = [ ];
    };

    custom.system.persistence.userConfig = {
      directories = [ ".config/sops" ];
    };
  };
}
