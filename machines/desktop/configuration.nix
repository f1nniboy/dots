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

    inherit (vars) user;

    apps = {
      # games
      sober.enable = true;
      steam.enable = true;
      luanti.enable = true;
      prismlauncher.enable = true;

      # adb.enable = true;
      #chromium.enable = true;

      monero.enable = true;
      #haveno.enable = true;

      tor.enable = true;
      mullvad-browser.enable = true;

      obs.enable = true;
      #gimp.enable = true;
      easyeffects.enable = true;
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
            homeDir = config.users.users."${config.custom.user.name}".home;
          in
          [
            "${homeDir}/source"
            "${homeDir}/bilder"
            "${homeDir}/dokumente"
            #"${homeDir}/.local/share/Haveno-reto"
          ];
      };

      docker.enable = true;
      audiomuse-worker.enable = false;

      xmrig = {
        enable = true;
        cpuUsage = 50; # 50% of 16 threads = 8 threads
      };
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
