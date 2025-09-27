{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.swap;
in
{
  options.custom.system.swap = {
    enable = mkEnableOption "Memory swapping";
  };

  config = mkIf cfg.enable {
    zramSwap.enable = true;
  };
}
