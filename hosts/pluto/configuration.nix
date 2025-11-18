{ config, ... }:
{
  custom = {
    presets = {
      base.enable = true;
      desktop.enable = true;
    };

    apps = {
      # games
      luanti.enable = true;
      prismlauncher.enable = true;
      supertux.enable = true;
      supertuxkart.enable = true;
      moonlight.enable = true;
    };

    services = {
      openssh.enable = true;
      mullvad.enable = true;

      syncthing = {
        devices = {
          diana = {
            id = "C6VRY6R-ZTMNATF-IQRP4XP-3DMFGM7-BVNDS5C-OINP5IC-RIQNQT5-R4T4ZQ4";
          };
        };
        folders =
          let
            homeDir = config.custom.system.home.dir;
          in
          {
            "${homeDir}/Documents/Wallets" = {
              id = "wallets";
              devices = [ "diana" ];
            };
            "${homeDir}/Documents/Notes" = {
              id = "notes";
              devices = [ "diana" ];
            };
          };
      };
    };

    system = {
      user = {
        sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICT4w58tzgbdbaJ33zNkUrV0eRWY+e5B/FQejghLR6dh";
      };
    };

    hardware = {
      gpu = {
        intel.enable = true;
      };
      fingerprint.enable = true;
    };
  };
}
