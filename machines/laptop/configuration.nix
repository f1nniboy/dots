{
  config,
  inputs,
  vars,
  ...
}:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager

    ../../common/presets/desktop.nix
  ];

  networking.hostName = "laptop";

  custom = {
    presets.desktop.enable = true;

    apps = {
      # games
      luanti.enable = true;
      prismlauncher.enable = true;
      supertux.enable = true;
      moonlight.enable = true;

      bitwarden.enable = true;

      openrgb.enable = true;
    };

    services = {
      mullvad.enable = true;

      syncthing = {
        devices = {
          desktop = {
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
              devices = [ "desktop" ];
            };
          };
      };
    };

    system = {
      user = {
        fullName = "Finn";
        name = "me";
        email = "me@f1nn.space";
        sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICT4w58tzgbdbaJ33zNkUrV0eRWY+e5B/FQejghLR6dh";
      };
      inherit (vars) ssh;

      persistence = {
        userConfig.directories = [ "source" ];
      };
      ld.enable = true;
    };

    hardware = {
      gpu = {
        intel.enable = true;
      };
      fingerprint.enable = true;
    };
  };
}
