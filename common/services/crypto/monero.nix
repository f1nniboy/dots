{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.monero;
in
{
  options.custom.services.monero = {
    enable = custom.enableOption;

    whitelist = mkOption {
      type = types.listOf types.str;
      description = "IPs that can connect to the unrestricted node";
      example = [ "123.123.123.123" ];
    };
  };

  config = mkIf cfg.enable {
    services.monero = {
      enable = true;
      dataDir = "/fun/srv/monero";
      limits = {
        download = -1;
        upload = -1;
      };
      # ref: https://www.coincashew.com/coins/overview-xmr/guide-or-how-to-run-a-full-node
      extraConfig = ''
        log-level=0

        confirm-external-bind=true

        public-node=false
        hide-my-port=true

        enforce-dns-checkpointing=true
        enable-dns-blocklist=true
        no-igd=true

        zmq-pub=tcp://127.0.0.1:18083

        out-peers=32
        in-peers=64
      '';
      priorityNodes = [
        "p2pmd.xmrvsbeast.com:18080"
        "nodes.hashvault.pro:18080"
      ];
    };

    custom.services = {
      caddy.hosts = {
        monero = {
          subdomain = "xmr";
          target = ":${toString config.services.monero.rpc.port}";

          # only permit usage of monero node on specific devices
          extra = ''
            @blocked not remote_ip ${concatStringsSep " " cfg.whitelist}
            respond @blocked 403
          '';
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ 18080 ];
    };

    systemd.tmpfiles.rules = [
      "d /fun/srv/monero 0700 monero monero - -"
    ];
  };
}
