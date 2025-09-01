{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.xmrig;
in
{
  options.custom.services.xmrig = {
    enable = mkEnableOption "XMRig Monero miner";
    host = mkOption {
      description = "IP or hostname of P2Pool instance";
      type = types.str;
      default = "100.100.10.10";
    };
    port = mkOption {
      type = types.port;
      default = 3333;
    };
    cpuUsage = mkOption {
      description = "Percentage of CPU threads to use";
      type = types.int;
      default = 100;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.xmrig ];

    services.xmrig = {
      enable = true;
      settings = {
        autosave = true;
        cpu = {
          "max-threads-hint" = cfg.cpuUsage;
        };
        randomx = {
          "1gb-pages" = true;
        };
        pools = [
          {
            url = "${cfg.host}:${toString cfg.port}";
          }
        ];
      };
    };
  };
}
