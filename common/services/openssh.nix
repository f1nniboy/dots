{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.openssh;
in
{
  options.custom.services.openssh = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        # ref: https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-20-04
        PermitRootLogin = "no";
        PasswordAuthentication = true;
        PermitEmptyPasswords = false;
        ChallengeResponseAuthentication = false;
        PermitUserEnvironment = false;
        AllowAgentForwarding = false;
        AllowTcpForwarding = false;
        PermitTunnel = false;
      };
      openFirewall = true;
    };
  };
}
