{ config, lib, ... }:
with lib;
let
  cfg = config.custom.hardware.audio;
in
{
  options.custom.hardware.audio = {
    enable = mkEnableOption "audio support";
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;

    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
      };
      pulseaudio.enable = mkForce false;
    };

    users.users.${config.custom.user.name} = {
      extraGroups = [ "audio" ];
    };
  };
}
