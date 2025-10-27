{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.i2pd;
in
{
  options.custom.services.i2pd = {
    enable = custom.enableOption;

    address = mkOption {
      type = types.str;
      default = "0.0.0.0";
    };

    port = mkOption {
      type = types.port;
      default = 14382;
    };
  };

  config = mkIf cfg.enable {
    services.i2pd = {
      enable = true;
      inherit (cfg) address port;
      bandwidth = 10000; # 10mb/s
      floodfill = true;
      nat = false;
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
          inherit (cfg) address;
        };
        socksProxy = {
          enable = true;
          inherit (cfg) address;
        };
        httpProxy = {
          enable = true;
          inherit (cfg) address;
        };
      };
    };

    custom.services = {
      caddy.hosts = {
        i2pd = {
          subdomain = "i2p";
          target = ":${toString config.services.i2pd.proto.http.port}";
          import = [ "auth" ];
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        7070 # web interface port
        4447 # socks proxy
        4444 # http proxy
        cfg.port
      ];
      allowedUDPPorts = [
        cfg.port
      ];
    };

    custom.system.persistence.config = {
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
}
