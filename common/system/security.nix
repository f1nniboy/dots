{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.security;
in
{
  options.custom.system.security = {
    enable = mkEnableOption "security tweaks";
  };

  config = mkIf cfg.enable {
    security.sudo.wheelNeedsPassword = false;
    networking.firewall.enable = true;
  };
}
