{
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
    "app.normandy.first_run" = false;
    "browser.aboutwelcome.enabled" = false;
    "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;

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

    # disable spellchecker
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

    # allow extensions to be auto-enabled
    "extensions.autoDisableScopes" = 0;

    # disable about:config warning
    "browser.aboutConfig.showWarning" = false;

    # disable PiP
    "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;

    # use xdg file picker
    "widget.use-xdg-desktop-portal.file-picker" = 1;

    # hide bookmark toolbar
    "browser.toolbars.bookmarks.visibility" = "never";
  }