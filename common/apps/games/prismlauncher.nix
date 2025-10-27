{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.prismlauncher;
in
{
  options.custom.apps.prismlauncher = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.prismlauncher
    ];

    custom.system.persistence.userConfig = {
      directories = [ ".local/share/PrismLauncher" ];
    };
  };
}
