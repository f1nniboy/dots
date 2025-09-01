{ config, lib, ... }:
with lib;
let
  cfg = config.custom.hardware.network;
in
{
  options.custom.hardware.network = {
    enable = mkEnableOption "networking support";
  };

  config = mkIf cfg.enable {
    users.users.${config.custom.user.name}.extraGroups = [ "networkmanager" ];

    networking = {
      networkmanager = {
        enable = true;
        dhcp = "internal";
      };

      firewall.enable = true;
    };

    # ref: https://github.com/NixOS/nixpkgs/issues/180175
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
