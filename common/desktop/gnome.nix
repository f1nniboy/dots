{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.desktop.gnome;
in
{
  options.custom.desktop.gnome = {
    enable = mkEnableOption "GNOME desktop environment";
  };

  config = mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;
        excludePackages = [ pkgs.xterm ];
      };
      displayManager.gdm = {
        enable = true;
        autoSuspend = false;
      };
      desktopManager.gnome.enable = true;
      gnome = {
        core-apps.enable = false;
        games.enable = false;
        core-developer-tools.enable = false;
      };
    };

    environment = {
      systemPackages = with pkgs; [
        gnomeExtensions.appindicator
        gnomeExtensions.blur-my-shell
        gnomeExtensions.clipboard-indicator
        gnomeExtensions.just-perfection
        gnomeExtensions.rounded-corners
        gnomeExtensions.tailscale-qs
        gnomeExtensions.grand-theft-focus

        nautilus
        decibels
        loupe
        gnome-calendar
        gnome-weather
        gnome-text-editor
        file-roller

        showtime
        resources
        impression
        papers
        errands

        wl-clipboard
      ];
      gnome.excludePackages = with pkgs; [
        gnome-color-manager
        gnome-tour
        gnome-user-docs
        gnome-menus
      ];
    };

    custom.system.persistence.userConfig = {
      directories = [
        # gnome online accounts
        ".config/goa-1.0"
        ".config/evolution"
      ];

      files = [
        # settings -> displays
        ".config/monitors.xml"
      ];
    };

    custom.system.home.extraOptions = {
      xdg.mimeApps = let
        apps = {
          image = "org.gnome.Loupe.desktop";
        };
      in {
        enable = true;
        defaultApplications = {
          "image/png" = apps.image;
          "image/jpeg" = apps.image;
          "image/webp" = apps.image;
        };
      };

      dconf.settings = let
        bgPath = "file:///run/current-system/sw/share/backgrounds/gnome";
        bg = {
          light = "${bgPath}/amber-l.jxl";
          dark = "${bgPath}/amber-d.jxl";
        };
      in {
        "org/gnome/shell" = {
          favorite-apps = [
            "org.gnome.Nautilus.desktop"
            "org.gnome.Ptyxis.desktop"
            "code.desktop"
            "firefox.desktop"
          ];
          disable-user-extensions = false;

          # `gnome-extensions list`
          enabled-extensions = [
            "appindicatorsupport@rgcjonas.gmail.com"
            "blur-my-shell@aunetx"
            "clipboard-indicator@tudmotu.com"
            "just-perfection-desktop@just-perfection"
            "Rounded_Corners@lennart-k"
            "tailscale@joaophi.github.com"
            "grand-theft-focus@zalckos.github.com"
          ];
        };
        "org/gnome/desktop/background" = {
          picture-uri = bg.light;
          picture-uri-dark = bg.dark;
        };
        "org/gnome/desktop/screensaver" = {
          picture-uri = bg.light;
          picture-uri-dark = bg.dark;
        };
        "org/gnome/GWeather4" = {
          temperature-unit = "centigrade";
        };
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          accent-color = "purple";
          gtk-enable-primary-paste = false;
          show-battery-percentage = true;
        };
        "org/gnome/desktop/peripherals/touchpad" = {
          disable-while-typing = false;
        };
        "org/gnome/desktop/wm/preferences" = {
          action-middle-click-titlebar = "minimize";
          button-layout = "appmenu:minimize,close";
          num-workspaces = 10;
        };
        "org/gnome/desktop/wm/keybindings" = {
          switch-to-workspace-1 =  [ "<Super>1" ];
          switch-to-workspace-2 =  [ "<Super>2" ];
          switch-to-workspace-3 =  [ "<Super>3" ];
          switch-to-workspace-4 =  [ "<Super>4" ];
          switch-to-workspace-5 =  [ "<Super>5" ];
          switch-to-workspace-6 =  [ "<Super>6" ];
          switch-to-workspace-7 =  [ "<Super>7" ];
          switch-to-workspace-8 =  [ "<Super>8" ];
          switch-to-workspace-9 =  [ "<Super>9" ];
          switch-to-workspace-10 = [ "<Super>0" ];

          move-to-workspace-1 =  [ "<Shift><Super>1" ];
          move-to-workspace-2 =  [ "<Shift><Super>2" ];
          move-to-workspace-3 =  [ "<Shift><Super>3" ];
          move-to-workspace-4 =  [ "<Shift><Super>4" ];
          move-to-workspace-5 =  [ "<Shift><Super>5" ];
          move-to-workspace-6 =  [ "<Shift><Super>6" ];
          move-to-workspace-7 =  [ "<Shift><Super>7" ];
          move-to-workspace-8 =  [ "<Shift><Super>8" ];
          move-to-workspace-9 =  [ "<Shift><Super>9" ];
          move-to-workspace-10 = [ "<Shift><Super>0" ];
        };
        "org/gnome/shell/keybindings" = {
          # remove the default hotkeys for opening favorited applications
          switch-to-application-1  = [ ];
          switch-to-application-2  = [ ];
          switch-to-application-3  = [ ];
          switch-to-application-4  = [ ];
          switch-to-application-5  = [ ];
          switch-to-application-6  = [ ];
          switch-to-application-7  = [ ];
          switch-to-application-8  = [ ];
          switch-to-application-9  = [ ];
          switch-to-application-10 = [ ];
        };
        "org/gnome/mutter" = {
          dynamic-workspaces = false;
        };
        "org/gnome/settings-daemon/plugins/power" = {
          # don't suspend after inactivity
          sleep-inactive-ac-type = "nothing";
        };

        "org/gnome/desktop/app-folders" = {
          # remove all folders from overview
          folder-children = [];
        };

        # extensions
        "org/gnome/shell/extensions/just-perfection" = {
          search = false;
          workspace-switcher-size = 10;
          world-clock = false;
          events-button = false;
          show-apps-icon = false;

          # disable donation popup
          support-notifier-type = 0;
        };
        "org/gnome/shell/extensions/appindicator" = {
          icon-saturation = 1.0;
        };
        "org/gnome/shell/extensions/clipboard-indicator" = {
          history-size = 250;
          cache-size = 10;
        };
      };
    };
  };
}
