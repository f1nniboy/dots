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
    # ref: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.firefox.profiles._name_.containersForce
    containersForce = true;

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
        # contains extension GUIDs that need to match entries in
        # ${baseDir}/firefox/default/storage/default (persisted above)
        "${baseDir}/firefox/default/prefs.js"
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

        # extension settings
        "3rdparty" = {
          Extensions = {
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              environment = {
                base = "https://vault.f1nn.space";
              };
            };
          };
        };

        # check about:support for extension/add-on ID strings
        # valid strings for installation_mode are:
        # - "allowed", "blocked", "force_installed", "normal_installed"
        ExtensionSettings = {
          "*".installation_mode = "blocked";
          # ublock origin
          #"uBlock0@raymondhill.net" = {
          #	install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          #	installation_mode = "force_installed";
          #};
          # bitwarden
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
          # sponsorblock
          #"sponsorBlocker@ajay.app" = {
          #	install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          #	installation_mode = "force_installed";
          #};
          # return youtube dislike
          #"{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
          #	install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
          #	installation_mode = "force_installed";
          #};
          # i don't care about cookies
          #"{cb6d2acf-7b2a-4b02-a561-b0092576b252}" = {
          #	install_url = "https://addons.mozilla.org/firefox/downloads/latest/i-dont-care-about-cookies/latest.xpi";
          #	installation_mode = "force_installed";
          #};
          # privacy badger
          #"jid1-MnnxcxisBPnSXQ@jetpack" = {
          #	install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
          #	installation_mode = "force_installed";
          #};
        };
      };
    };

    custom.system.home.extraOptions = {
      home.file = {
          "${baseDir}/firefox/default/chrome/firefox-gnome-theme" = {
            source = inputs.firefox-gnome-theme;
          };
      };

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
          }
        ];
      };
    };
  };
}
