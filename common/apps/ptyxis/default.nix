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
  profileUuid = "default";
in
{
  options.custom.apps.ptyxis = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.ptyxis ];

    custom.system.home.extraOptions = {
      dconf.settings = {
        "org/gnome/Ptyxis" = {
          profile-uuids = [ profileUuid ];
          default-profile-uuid = profileUuid;
          window-size =
            with inputs.home-manager.lib.hm.gvariant;
            mkTuple [
              (mkUint32 110)
              (mkUint32 30)
            ];
        };
        "org/gnome/Ptyxis/Profiles/${profileUuid}" = {
          label = "Standard";
          bold-is-bright = true;
        };
      };
    };
  };
}
