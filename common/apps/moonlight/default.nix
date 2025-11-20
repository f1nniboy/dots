{ config, lib, ... }:
with lib;
let
  cfg = config.custom.apps.moonlight;
in
{
  options.custom.apps.moonlight = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    services.flatpak.packages = [
      "flathub:app/com.moonlight_stream.Moonlight//stable"
    ];
  };
}
