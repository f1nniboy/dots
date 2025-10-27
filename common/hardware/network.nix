{ config, lib, ... }:
with lib;
let
  cfg = config.custom.hardware.network;
in
{
  options.custom.hardware.network = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    users.users.${config.custom.system.user.name} = {
      extraGroups = [ "networkmanager" ];
    };

    networking = {
      networkmanager = {
        enable = true;
        dhcp = "internal";

        # disable NetworkManager's internal DNS resolution
        dns = "none";
      };

      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "8.8.8.8"
        "8.8.4.4"
      ];
    };

    # ref: https://github.com/NixOS/nixpkgs/issues/180175
    systemd.services.NetworkManager-wait-online.enable = false;

    custom.system.persistence.config = {
      directories = [ "/etc/NetworkManager/system-connections" ];
    };
  };
}
