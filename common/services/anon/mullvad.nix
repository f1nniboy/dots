{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.mullvad;
  mullvad-autostart = pkgs.makeAutostartItem {
    name = "mullvad-vpn";
    package = pkgs.mullvad-vpn;
  };
in
{
  options.custom.services.mullvad = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mullvad-vpn
      mullvad
      mullvad-autostart
    ];

    services.mullvad-vpn = {
      enable = true;
    };

    systemd = {
      services."mullvad-daemon" = {
        environment.MULLVAD_SETTINGS_DIR = "/var/lib/mullvad-vpn";
      };
    };

    # make mullvad work simultaneously with tailscale
    networking.nftables = {
      # TODO: ENABLE AGAIN (doesnt work with docker)
      enable = false;
      ruleset = ''
        table inet mullvad_tailscale {
          chain output {
            type route hook output priority 0; policy accept;
            ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
          }
        }
      '';
    };

    custom.system.home = {
      configFiles = {
        "Mullvad VPN/gui_settings.json" = {
          text = builtins.toJSON {
            monochromaticIcon = true;
            animateMap = true;
            startMinimized = true;

            preferredLocale = "system";
            autoConnect = true;
            enableSystemNotifications = true;
            unpinnedWindow = true;
            browsedForSplitTunnelingApplications = [ ];
            changelogDisplayedForVersion = "2025.7";
          };
        };
      };
    };

    custom.system.persistence.config = {
      directories = [
        {
          directory = "/var/lib/mullvad-vpn";
          user = "root";
          group = "root";
          mode = "0700";
        }
      ];
    };
  };
}
