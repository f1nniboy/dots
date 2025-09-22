{
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
    };

    services = {
      mullvad.enable = true;
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
      fingerprint.enable = true;
    };
  };
}
