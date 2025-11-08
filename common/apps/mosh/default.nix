{ config, lib, ... }:
with lib;
let
  cfg = config.custom.apps.mosh;
in
{
  options.custom.apps.mosh = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    programs.mosh.enable = true;
  };
}
