{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.remoteUnlock;
in
{
  options.custom.system.remoteUnlock = {
    enable = mkEnableOption "LUKS unlock over SSH";
  };

  config = mkIf cfg.enable {
    boot.kernelParams = [ "ip=dhcp" ];

    boot.initrd.network = {
      enable = true;
      ssh = {
        enable = true;
        shell = "/bin/cryptsetup-askpass";
        authorizedKeys = [ config.custom.user.sshPublicKey ];
        hostKeys = [ "/nix/secret/initrd/ssh_host_ed25519_key" ];
      };
    };
  };
}
