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

  networking.hostName = "desktop";

  custom = {
    presets.desktop.enable = true;

    apps = {
      # games
      sober.enable = true;
      steam.enable = true;
      luanti.enable = true;
      prismlauncher.enable = true;
      supertux.enable = true;

      adb.enable = true;

      monero.enable = true;
      haveno.enable = true;

      tor.enable = true;
      mullvad-browser.enable = true;

      obs.enable = true;
      gimp.enable = true;
      easyeffects.enable = true;

      bitwarden.enable = true;

      openrgb.enable = true;
    };

    services = {
      mullvad.enable = true;

      restic = {
        enable = true;
        frequency = "daily";
        repos = {
          borgbase = true;
        };
        paths =
          let
            homeDir = config.users.users."${config.custom.system.user.name}".home;
          in
          [
            "${homeDir}/source"
            "${homeDir}/bilder"
            "${homeDir}/dokumente"
            "${homeDir}/.local/share/Haveno-reto"
          ];
      };

      xmrig = {
        enable = false;
        cpuUsage = 50;
      };

      docker.enable = true;

      gow = {
        enable = true;
      };
    };

    hardware = {
      wheel.enable = true;
    };

    system = {
      user = {
        fullName = "Finn";
        name = "me";
        email = "me@f1nn.space";
        sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBK67b6pvKUWVH/lflBvW7TI6DTXy7xT7iM8xpvHvbi0";
      };
      inherit (vars) ssh;

      ld.enable = true;
      persistence = {
        userConfig.directories = [ "source" ".node-llama-cpp" ];
      };
    };
  };
}
