{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.ld;
in
{
  options.custom.system.ld = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    programs.nix-ld.enable = true;
  };
}
