{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.env;
in
{
  options.custom.system.env = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.variables = {
      EDITOR = "nvim";
    };
  };
}
