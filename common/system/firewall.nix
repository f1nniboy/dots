{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.firewall;
in
{
  options.custom.system.firewall = {
    enable = custom.enableOption;

    backend = mkOption {
      type = types.enum [
        "nftables"
        "iptables"
      ];
      default = "iptables";
    };

    rules = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    networking = {
      firewall.enable = true;

      nftables = mkIf (cfg.backend == "nftables") {
        enable = true;
        ruleset = builtins.concatStringsSep "\n" cfg.rules;
      };
    };
  };
}
