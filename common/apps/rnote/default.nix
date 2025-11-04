{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.rnote;

  homeDir = config.custom.system.home.dir;
  notesDir = "${homeDir}/Documents/Notes";
in
{
  options.custom.apps.rnote = {
    enable = custom.enableOption;
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.rnote ];

    systemd.user.tmpfiles.rules = [
      "d ${notesDir} - - - - -"
    ];

    custom.services.restic.paths = [
      notesDir
    ];
  };
}
