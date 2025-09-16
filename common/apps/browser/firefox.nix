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
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.firefox.profiles._name_.containersForce
    containersForce = true;

    search = {
      force = true;
      default = "ddg";
    };
  };
  baseSettings = {
    # disable first-run stuff
    "browser.disableResetPrompt" = true;
    "browser.download.panel.shown" = true;
    "browser.feeds.showFirstRunUI" = false;
    "browser.messaging-system.whatsNewPanel.enabled" = false;
    "browser.rights.3.shown" = true;
    "browser.shell.checkDefaultBrowser" = false;
    "browser.shell.defaultBrowserCheckCount" = 1;
    "browser.startup.homepage_override.mstone" = "ignore";
    "browser.uitour.enabled" = false;
    "startup.homepage_override_url" = "";
    "trailhead.firstrun.didSeeAboutWelcome" = true;
    "browser.bookmarks.restore_default_bookmarks" = false;
    "browser.bookmarks.addedImportButton" = true;

    # clean up browser history & unwanted cookies on restart
    "privacy.sanitize.sanitizeOnShutdown" = true;
    "privacy.clearOnShutdown_v2.cache" = true;
    "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
    "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;
    "privacy.clearOnShutdown_v2.downloads" = true;
    "privacy.clearOnShutdown_v2.formdata" = true;
    "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
    "privacy.clearSiteData.cache" = true;
    "privacy.clearSiteData.cookiesAndStorage" = false;
    "privacy.clearSiteData.historyFormDataAndDownloads" = true;
    "privacy.clearSiteData.browsingHistoryAndDownloads" = true;
    "privacy.clearSiteData.formdata" = true;
    "privacy.clearHistory.cache" = true;
    "privacy.clearHistory.cookiesAndStorage" = false;
    "privacy.clearHistory.historyFormDataAndDownloads" = true;
    "privacy.clearHistory.browsingHistoryAndDownloads" = true;
    "privacy.clearHistory.formdata" = true;
    "privacy.sanitize.timeSpan" = 0;

    # disable some telemetry
    "app.shield.optoutstudies.enabled" = false;
    "browser.discovery.enabled" = false;
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.ping-centre.telemetry" = false;
    "datareporting.healthreport.service.enabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "datareporting.sessions.current.clean" = true;
    "devtools.onboarding.telemetry.logged" = false;
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.bhrPing.enabled" = false;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
    "toolkit.telemetry.hybridContent.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.prompted" = 2;
    "toolkit.telemetry.rejected" = true;
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "toolkit.telemetry.server" = "";
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.unifiedIsOptIn" = false;
    "toolkit.telemetry.updatePing.enabled" = false;

    # don't ask for download dir
    "browser.download.useDownloadDir" = false;

    # disable forms & saved passwords
    "signon.rememberSignons" = false;
    "browser.formfill.enable" = false;
    "signon.autofillForms" = false;
    "signon.formlessCapture.enabled" = false;

    # avoid using disk cache
    "browser.cache.disk.enable" = false;
    "browser.privatebrowsing.forceMediaMemoryCache" = true;
    "media.memory_cache_max_size" = 65536;
    "browser.sessionstore.privacy_level" = 2;

    # harden
    "privacy.trackingprotection.enabled" = true;
    "dom.security.https_only_mode" = true;

    "layout.spellcheckDefault" = 0; # 0 = disabled, 1 = multi-line, 2 = single and multi-line

    # new tab
    "browser.startup.page" = 0;
    "browser.startup.homepage" = "about:blank";
    "browser.newtabpage.enabled" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.default.sites" = "";

    # theme
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "svg.context-properties.content.enabled" = true;
  };
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

        # check about:support for extension/add-on ID strings
        # valid strings for installation_mode are:
        # - "allowed", "blocked", "force_installed", "normal_installed"
        ExtensionSettings = {
          "*".installation_mode = "allowed";y
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
