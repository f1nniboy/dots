{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.moonlight;
in
{
  options.custom.apps.moonlight = {
    enable = mkEnableOption "Game streamingclient";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.moonlight-qt
    ];

    custom.system.persistence.userConfig = {
      directories = [ ".config/Moonlight Game Streaming Project" ];
    };
  };
}
