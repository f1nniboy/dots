{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.remoteUnlock;
in
{
  options.custom.system.remoteUnlock = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    boot.kernelParams = [ "ip=dhcp" ];

    boot.initrd.network = {
      enable = true;
      ssh = {
        enable = true;
        shell = "/bin/cryptsetup-askpass";
        inherit (config.custom.system.ssh) authorizedKeys;
        hostKeys = [ "/nix/secret/initrd/ssh_host_ed25519_key" ];
      };
    };
  };
}
