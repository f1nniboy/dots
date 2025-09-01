{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.env;
in
{
  options.custom.system.env = {
    enable = mkEnableOption "environment variables";
  };

  config = mkIf cfg.enable {
    environment.variables = {
      EDITOR = "nvim";
    };
  };
}
