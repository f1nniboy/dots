{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.tor;
  baseDir = ".tor project";
  profileName = "default";
in
{
  options.custom.apps.tor = {
    enable = mkEnableOption "Tor browser";
  };

  # ref: https://github.com/BryceBeagle/nixos-config/blob/main/firefox.nix
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.tor-browser ];

    custom.system.persistence.userConfig = {
      files = [
        "${baseDir}/firefox/${profileName}/cookies.sqlite"
        "${baseDir}/firefox/${profileName}/favicons.sqlite"
        # Permissions and zoom levels for each site
        "${baseDir}/firefox/${profileName}/permissions.sqlite"
        "${baseDir}/firefox/${profileName}/content-prefs.sqlite"
        # I guess this is useful?
        # https://bugzilla.mozilla.org/show_bug.cgi?id=1511384
        # https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria
        "${baseDir}/firefox/${profileName}/storage.sqlite"
      ];
    };

    custom.system.home.extraOptions = {
      home.file = {
        "${baseDir}/firefox/profiles.ini" = {
          text = ''
            [General]
            StartWithLastProfile=1
            Version=2

            [Profile0]
            Default=1
            IsRelative=1
            Name=${profileName}
            Path=${profileName}
            					'';
        };
      };
    };

  };
}
