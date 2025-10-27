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
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    services.flatpak.packages = [
      ":${
        pkgs.fetchurl {
          url = "https://github.com/retoaccess1/haveno-reto/releases/download/1.2.2-reto/haveno-v1.2.2-linux-x86_64.flatpak";
          sha256 = "0fz3n2y5jrrlcbfmfr57bwgmaawdmmwwanigz23kgjzfrzbzpm8b";
        }
      }"
    ];

    custom.system.persistence.userConfig = {
      directories = [ ".local/share/Haveno-reto" ];
    };
  };
}
