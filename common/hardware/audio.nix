{ config, lib, ... }:
with lib;
let
  cfg = config.custom.hardware.audio;
in
{
  options.custom.hardware.audio = {
    enable = custom.enableOption;
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

    users.users.${config.custom.system.user.name} = {
      extraGroups = [ "audio" ];
    };
  };
}
