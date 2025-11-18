{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.i2pd;
  address = "0.0.0.0";
in
{
  options.custom.services.i2pd = {
    enable = custom.enableOption;

    port = mkOption {
      type = types.port;
      default = 14382;
    };
  };

  config = mkIf cfg.enable {
    services.i2pd = {
      enable = true;
      inherit address;
      inherit (cfg) port;
      #bandwidth = 10000; # 10mb/s
      limits = {
        transittunnels = 10000;
      };
      addressbook = {
        subscriptions = [
          "http://notbob.i2p/hosts-all.txt"
          "http://stats.i2p/cgi-bin/newhosts.txt"
          "http://skank.i2p/hosts.txt"
        ];
      };
      proto = {
        http = {
          enable = true;
          strictHeaders = false;
          inherit address;
        };
        socksProxy = {
          enable = true;
          inherit address;
        };
        httpProxy = {
          enable = true;
          inherit address;
        };
      };
    };

    custom = {
      services = {
        caddy.hosts = {
          i2pd = {
            target = ":${toString config.services.i2pd.proto.http.port}";
            import = [ "auth" ];
          };
        };
      };
      system.persistence.config = {
        directories = [
          {
            directory = "/var/lib/i2pd";
            user = "i2pd";
            group = "i2pd";
            mode = "0700";
          }
        ];
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];

      interfaces."${config.services.tailscale.interfaceName}" = {
        allowedTCPPorts =
          let
            inherit (config.services.i2pd) proto;
          in
          [
            proto.socksProxy.port
            proto.httpProxy.port
          ];
      };
    };
  };
}
