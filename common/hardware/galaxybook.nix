{ config, lib, ... }:
with lib;
let
  cfg = config.custom.hardware.galaxybook;
in
{
  options.custom.hardware.galaxybook = {
    enable = mkEnableOption "Samsung Galaxybook-specific tweaks";
  };

  config = mkIf cfg.enable {
    boot.extraModprobeConfig = ''
      options snd-hda-intel model=alc298-samsung-amp-v2-2-amps
    ''; 
    # TODO: try options snd-hda-intel model=alc298-samsung-amp-v2-4-amps
  };
}
