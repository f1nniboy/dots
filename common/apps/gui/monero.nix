{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.monero;
in
{
  options.custom.apps.monero = {
    enable = mkEnableOption "Monero GUI & CLI";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      monero-gui
      monero-cli
    ];

    custom.system.persistence.userConfig = {
      directories = [ ".config/monero-project" ];
    };
  };
}
