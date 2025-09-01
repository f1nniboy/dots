{ config, lib, ... }:
with lib;
let
  cfg = config.custom.apps.sober;
in
{
  options.custom.apps.sober = {
    enable = mkEnableOption "Roblox player for Linux";
  };

  config = mkIf cfg.enable {
    services.flatpak.packages = [
      "flathub:app/org.vinegarhq.Sober//stable"
    ];
  };
}
