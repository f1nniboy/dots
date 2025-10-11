{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.haveno;
in
{
  options.custom.apps.haveno = {
    enable = mkEnableOption "P2P decentralized XMR exchange";
  };

  config = mkIf cfg.enable {
    services.flatpak.packages = [
      ":${
        pkgs.fetchurl {
          url = "https://github.com/retoaccess1/haveno-reto/releases/download/1.2.1-1/haveno-v1.2.0-linux-x86_64.flatpak";
          sha256 = "sha256-z1C2ku2OmLP3dm7V5iZSSfp1tWqHpBy4YYVbMYJ/Uec=";
        }
      }"
    ];

    custom.system.persistence.userConfig = {
      directories = [ ".local/share/Haveno-reto" ];
    };
  };
}
