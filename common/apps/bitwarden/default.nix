{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
with lib;
let
  cfg = config.custom.apps.bitwarden;
  configFile = pkgs.writeTextFile {
    name = "data.json";
    text = import ./config.nix {
      inherit vars;
    };
  };
in
{
  options.custom.apps.bitwarden = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.bitwarden-desktop ];

    systemd.user.tmpfiles.rules =
      let
        homeDir = config.custom.system.home.dir;
      in
      [
        "C ${homeDir}/.config/Bitwarden/data.json - - - - ${configFile}"
      ];

    custom.system.persistence.userConfig = {
      directories = [ ".config/Bitwarden" ];
    };
  };
}
