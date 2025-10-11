{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.rnote;

  homeDir = config.users.users."${config.custom.system.user.name}".home;
  notesDir = "${homeDir}/Documents/Notes";
in
{
  options.custom.apps.rnote = {
    enable = mkEnableOption "Sketch and take handwritten notes";
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
