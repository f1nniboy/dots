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

    inherit (vars) user;

    apps = {
    };

    services = {
      mullvad.enable = true;
    };

    hardware = {
      wheel.enable = true;
    };

    system = {
      persistence = {
        userConfig.directories = [ "source" ];
      };
      ld.enable = true;
    };
  };
}
