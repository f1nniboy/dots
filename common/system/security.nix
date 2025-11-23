{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.security;
in
{
  options.custom.system.security = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    security.sudo.wheelNeedsPassword = false;
  };
}
