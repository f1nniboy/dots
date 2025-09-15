{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.ptyxis;
in
{
  options.custom.apps.ptyxis = {
    enable = mkEnableOption "Ptyxis GNOME terminal";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.ptyxis ];

    custom.system.home.extraOptions = {
      dconf.settings = {
        "org/gnome/Ptyxis" = {
          profile-uuids = [ "default" ];
          default-profile-uuid = "default";
          window-size = with inputs.home-manager.lib.hm.gvariant; mkTuple [
            (mkUint32 110)
            (mkUint32 30)
          ];
        };
        "org/gnome/Ptyxis/Profiles/default" = {
          label = "Standard";
          bold-is-bright = true;
        };
      };
    };
  };
}
