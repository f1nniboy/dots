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
    };

    services = {
      mullvad.enable = true;
    };

    system = {
      user = {
        fullName = "Finn";
        name = "me";
        email = "me@f1nn.space";
        sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBK67b6pvKUWVH/lflBvW7TI6DTXy7xT7iM8xpvHvbi0";
      };
      inherit (vars) ssh;

      persistence = {
        userConfig.directories = [ "source" ];
      };
      ld.enable = true;
    };
  };
}
