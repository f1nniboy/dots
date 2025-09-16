{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.networking;
in
{
  options.custom.system.networking = {
    enable = mkEnableOption "network stuff";
  };

  config = mkIf cfg.enable {
    # disable NetworkManager's internal DNS resolution
    networking.networkmanager.dns = "none";

    networking.nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
  };
}
