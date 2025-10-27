{ config, lib, ... }:
with lib;
let
  cfg = config.custom.presets.base;
in
{
  options.custom.presets.base = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    custom = {
      system = {
        boot.enable = true;
        env.enable = true;
        locale.enable = true;
        nix.enable = true;
        packages.enable = true;
        persistence.enable = true;
        security.enable = true;
        sops.enable = true;
        ssh.enable = true;
        swap.enable = true;
        xdg.enable = true;
      };

      hardware = {
        network.enable = true;
      };
    };
  };
}
