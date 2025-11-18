{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.xmrig;
in
{
  options.custom.services.xmrig = {
    enable = custom.enableOption;
    host = mkOption {
      description = "host of P2Pool instance";
      type = types.str;
      default = custom.mkServiceDomain config "p2pool";
    };
    port = mkOption {
      type = types.port;
      default = 3333;
    };
    cpuUsage = mkOption {
      description = "percentage of CPU threads to use";
      type = types.int;
      default = 100;
    };
  };

  config = mkIf cfg.enable {
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
