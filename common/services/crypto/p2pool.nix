{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.p2pool;
in
{
  options.custom.services.p2pool = {
    enable = mkEnableOption "P2Pool for decentralized XMR mining";

    wallet = mkOption {
      type = types.str;
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/p2pool";
    };

    ports = mkOption {
      type = types.submodule {
        options = {
          stratum = mkOption {
            type = types.port;
            default = 3333;
          };
          p2p = mkOption {
            type = types.port;
            default = 37888;
          };
        };
      };
      default = { };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.p2pool ];

    users = {
      users.p2pool = {
        isSystemUser = true;
        group = "p2pool";
        description = "P2Pool daemon user";
        home = cfg.dataDir;
        createHome = true;
      };
      groups.p2pool = { };
    };

    systemd.services.p2pool = {
      description = "p2pool daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "p2pool";
        Group = "p2pool";
        ExecStart = "${pkgs.p2pool}/bin/p2pool --p2p 0.0.0.0:${toString cfg.ports.p2p} --mini --wallet ${cfg.wallet} --stratum 0.0.0.0:${toString cfg.ports.stratum} --no-upnp --no-randomx --light-mode --data-dir /var/lib/p2pool";
        Restart = "always";
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        cfg.ports.stratum
        cfg.ports.p2p
      ];
      allowedUDPPorts = [
        cfg.ports.stratum
        cfg.ports.p2p
      ];
    };
  };
}
