{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.mullvad-browser;
in
{
  options.custom.apps.mullvad-browser = {
    enable = mkEnableOption "Privacy-focused browser";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.mullvad-browser ];

    # no persistence for now, muh security
    #custom.system.persistence.userConfig = {
    #  directories = [ ".mullvad" ];
    #};
  };
}
