{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.mullvad;

  daemonSettingsFile = pkgs.writeTextFile {
    name = "settings.json";
    text = builtins.toJSON (import ./config.nix);
  };

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
    environment.systemPackages = [
      mullvad-autostart
    ];

    services.mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };

    systemd = {
      services."mullvad-daemon" = {
        environment.MULLVAD_SETTINGS_DIR = "/var/lib/mullvad-vpn";
      };

      tmpfiles.settings."10-mullvad-settings"."/var/lib/mullvad-vpn/settings.json"."C" = {
        argument = "${daemonSettingsFile}";
        mode = "0600";
      };
    };

    custom.system = {
      firewall = {
        rules = [
          # make mullvad work simultaneously with tailscale
          # ref: https://theorangeone.net/posts/tailscale-mullvad
          ''
            table inet mullvad_tailscale {
              chain output {
                type route hook output priority -100; policy accept;
                ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
              }

              chain input {
                type filter hook input priority -100; policy accept;
                ip saddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
              }
            }
          ''
        ];
      };

      persistence = {
        config.directories = [
          {
            directory = "/var/lib/mullvad-vpn";
            user = "root";
            group = "root";
            mode = "0700";
          }
        ];
        userConfig.directories = [
          ".config/Mullvad VPN"
        ];
      };
    };
  };
}
