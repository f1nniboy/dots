{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.bitwarden;
in
{
  options.custom.apps.bitwarden = {
    enable = mkEnableOption "Secure password vault";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.bitwarden-desktop ];

    custom.system.persistence.userConfig = {
      directories = [ ".config/Bitwarden" ];
    };
  };
}
