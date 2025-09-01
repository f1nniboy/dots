{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.unbound;
in
{
  options.custom.services.unbound = {
    enable = mkEnableOption "Unbound DNS";

    port = mkOption {
      type = types.port;
      default = 53;
    };

    zone = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    data = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    services.unbound = {
      enable = true;
      settings = {
        server = {
          interface = [ "0.0.0.0" ];
          inherit (cfg) port;
          access-control = [
            "127.0.0.1   allow"
            "100.0.0.0/8 allow"
          ];

          # ref: https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound
          harden-glue = true;
          harden-dnssec-stripped = true;
          use-caps-for-id = false;
          prefetch = true;
          edns-buffer-size = 1232;

          # custom settings
          hide-identity = true;
          hide-version = true;

          local-zone = cfg.zone;
          local-data = cfg.data;
        };
        forward-zone = [
          # quad9
          {
            name = ".";
            forward-addr = [
              "9.9.9.9#dns.quad9.net"
              "149.112.112.112#dns.quad9.net"
            ];
            forward-tls-upstream = true;
          }
        ];
      };
    };

    networking = {
      nameservers = [ "127.0.0.1" ];
      firewall = {
        allowedTCPPorts = [ cfg.port ];
        allowedUDPPorts = [ cfg.port ];
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/unbound";
          user = "unbound";
          group = "unbound";
          mode = "0700";
        }
      ];
    };
  };
}
