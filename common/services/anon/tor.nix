{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.tor;
in
{
  options.custom.services.tor = {
    enable = custom.enableOption;
    contact = mkOption {
      type = types.str;
    };
    port = mkOption {
      type = types.port;
      default = 49837;
    };
  };

  config = mkIf cfg.enable {
    services.tor = {
      enable = true;
      openFirewall = true;
      relay = {
        enable = true;
        role = "relay";
      };
      settings = {
        ContactInfo = cfg.contact;
        ORPort = cfg.port;
        BandWidthRate = "5 MBytes";
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    custom.system.persistence.config = {
      directories = [
        {
          directory = "/var/lib/tor";
          user = "tor";
          group = "tor";
          mode = "0700";
        }
      ];
    };
  };
}
