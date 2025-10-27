{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.steam;
in
{
  options.custom.apps.steam = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.steam-devices-udev-rules
    ];

    services.flatpak.packages = [
      "flathub:app/com.valvesoftware.Steam//stable"
    ];
  };
}
