{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.locale;
in
{
  options.custom.system.locale = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocales = [ "de_DE.UTF-8/UTF-8" ];
    time.timeZone = "Europe/Berlin";
    console.keyMap = "de";

    services.xserver.xkb = {
      layout = "de";
    };
  };
}
