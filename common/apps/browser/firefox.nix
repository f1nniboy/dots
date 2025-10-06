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
  baseProfile = {
    search = {
      force = true;
      default = "ddg";
    };
  };
  baseSettings = import ../config/firefox.nix;
in
{
  options.custom.apps.firefox = {
    enable = mkEnableOption "Firefox browser";
  };

  # ref: https://github.com/BryceBeagle/nixos-config/blob/main/firefox.nix
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.firefox ];

    custom.system.persistence.userConfig = {
      directories = [
        "${baseDir}/firefox/default/extensions/"
        # extension data is stored here, but also IndexedDB data for random websites
        # see https://github.com/BryceBeagle/nixos-config/issues/151
        "${baseDir}/firefox/default/storage/default/"
      ];
      files = [
        "${baseDir}/firefox/default/cookies.sqlite"
        "${baseDir}/firefox/default/favicons.sqlite"
        # permissions and zoom levels for each site
        "${baseDir}/firefox/default/permissions.sqlite"
        "${baseDir}/firefox/default/content-prefs.sqlite"
        # browser history and bookmarks
        "${baseDir}/firefox/default/places.sqlite"
        # i guess this is useful?
        # https://bugzilla.mozilla.org/show_bug.cgi?id=1511384
        # https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria
        "${baseDir}/firefox/default/storage.sqlite"
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
      file = {
        "${baseDir}/firefox/default/chrome/firefox-gnome-theme" = {
          source = inputs.firefox-gnome-theme;
        };
        "${baseDir}/firefox/profiles.ini".force = true;
      };

      extraOptions = {
        programs.firefox = {
          enable = true;

          profiles.default = mkMerge [
            baseProfile
            {
              id = 0;
              name = "default";
              isDefault = true;

              userChrome = ''@import "firefox-gnome-theme/userChrome.css";'';
              userContent = ''@import "firefox-gnome-theme/userContent.css";'';

              settings = baseSettings;

              extensions = {
                packages = with pkgs.nur.repos.rycee.firefox-addons; [
                  ublock-origin
                  bitwarden
                ];
              };
            }
          ];
        };
      };
    };
  };
}
