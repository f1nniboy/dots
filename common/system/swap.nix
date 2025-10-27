{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.swap;
in
{
  options.custom.system.swap = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    zramSwap.enable = true;
  };
}
