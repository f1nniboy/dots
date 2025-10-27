{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.firefox;
  baseDir = ".mozilla";
  profileName = "default";
  profileDir = "${baseDir}/firefox/${profileName}";
  profileSettings = {
    search = {
      force = true;
      default = "ddg";
    };

    userChrome = ''@import "firefox-gnome-theme/userChrome.css";'';
    userContent = ''@import "firefox-gnome-theme/userContent.css";'';

    extensions = {
      packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        bitwarden
      ];
    };

    settings = import ../config/firefox.nix;
  };
in
{
  options.custom.apps.firefox = {
    enable = custom.enableOption;
  };

  # ref: https://github.com/BryceBeagle/nixos-config/blob/main/firefox.nix
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.firefox ];

    custom.system.persistence.userConfig = {
      directories = [
        "${profileDir}/extensions/"
        # extension data is stored here, but also IndexedDB data for random websites
        # ref: https://github.com/BryceBeagle/nixos-config/issues/151
        "${profileDir}/storage/default/"
      ];
      files = [
        "${profileDir}/cookies.sqlite"
        "${profileDir}/favicons.sqlite"
        # permissions and zoom levels for each site
        "${profileDir}/permissions.sqlite"
        "${profileDir}/content-prefs.sqlite"
        # browser history and bookmarks
        "${profileDir}/places.sqlite"
        # i guess this is useful?
        # ref: https://bugzilla.mozilla.org/show_bug.cgi?id=1511384
        # ref: https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria
        "${profileDir}/storage.sqlite"
      ];
    };

    programs.firefox = {
      enable = true;
      languagePacks = [ "en-US" ];

      # about:policies#documentation
      policies = {
        DisableAppUpdate = true;
        DisableFirefoxAccounts = true;
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DontCheckDefaultBrowser = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DisplayBookmarksToolbar = "never"; # always / never / newtab
        DisplayMenuBar = "default-off"; # always / never / default-on / default-off
        NetworkPrediction = false;
        SearchSuggestEnabled = false;
      };
    };

    custom.system.home = {
      homeFiles = {
        "${profileDir}/chrome/firefox-gnome-theme" = {
          source = inputs.firefox-gnome-theme;
        };
        "${baseDir}/firefox/profiles.ini".force = true;
      };

      extraOptions = {
        programs.firefox = {
          enable = true;

          profiles.${profileName} = mkMerge [
            profileSettings
            {
              id = 0;
              name = profileName;
              isDefault = true;
            }
          ];
        };
      };
    };
  };
}
