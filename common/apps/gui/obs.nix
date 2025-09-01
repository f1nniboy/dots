{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.obs;
in
{
  options.custom.apps.obs = {
    enable = mkEnableOption "Open Broadcaster Studio";
  };

  config = mkIf cfg.enable {
    custom.system.persistence.userConfig = {
      directories = [ ".config/obs-studio" ];
    };

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-composite-blur
        obs-pipewire-audio-capture
        obs-stroke-glow-shadow
        obs-vkcapture
        obs-shaderfilter
      ];
    };
  };
}
