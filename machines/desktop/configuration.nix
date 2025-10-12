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

  networking = {
    hostName = "desktop";

    interfaces = {
      eno1 = {
        wakeOnLan.enable = true;
      };
    };
  };

  custom = {
    presets.desktop.enable = true;

    apps = {
      # games
      sober.enable = true;
      steam.enable = true;
      luanti.enable = true;
      prismlauncher.enable = true;
      supertux.enable = true;
      moonlight.enable = true;
      beammp-launcher.enable = true;

      adb.enable = true;

      haveno.enable = true;

      tor.enable = true;
      mullvad-browser.enable = true;

      obs.enable = true;
      gimp.enable = true;
      easyeffects.enable = true;

      bitwarden.enable = true;

      openrgb.enable = true;
    };

    media.enable = true;

    services = {
      mullvad.enable = true;

      restic =
        let
          homeDir = config.users.users."${config.custom.system.user.name}".home;
        in
        {
          enable = true;
          frequency = "daily";
          repos = {
            borgbase = true;
          };
          paths = [
            "${homeDir}/source"
            "${homeDir}/bilder"
            "${homeDir}/dokumente"
            "${homeDir}/.local/share/Haveno-reto"
          ];
          exclude = [
            "${homeDir}/source/**/node_modules"
          ];
        };

      xmrig = {
        enable = true;
        cpuUsage = 40;
      };

      openssh.enable = true;
      docker.enable = true;
      gow = {
        enable = true;
      };

      sabnzbd = {
        enable = true;
        dirs = {
          complete = "/fun/media/usenet/complete";
          incomplete = "/fun/media/usenet/incomplete";
        };
        categories = [
          {
            name = null;
            script = "None";
            dir = "";
          }
          {
            name = "games";
            script = "Default";
            dir = "games";
          }
        ];
      };

      syncthing = {
        devices = {
          laptop = {
            id = "LTQOADO-W75UWVR-FMADCWM-27LQTZI-5QYIE33-OE5EAMZ-USRCBPW-UZCROAK";
          };
        };
        folders =
          let
            homeDir = config.custom.system.home.dir;
          in
          {
            "${homeDir}/Documents/Wallets" = {
              id = "wallets";
              devices = [ "laptop" ];
            };
          };
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
        userConfig.directories = [
          "source"
          ".node-llama-cpp"
        ];
      };
    };
  };
}
