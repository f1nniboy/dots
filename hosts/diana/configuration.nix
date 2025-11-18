{ config, ... }:
let
  homeDir = config.custom.system.home.dir;
in
{
  custom = {
    presets = {
      base.enable = true;
      desktop.enable = true;
    };

    apps = {
      # games
      sober.enable = true;
      luanti.enable = true;
      prismlauncher.enable = true;
      supertux.enable = true;
      supertuxkart.enable = true;
      xonotic.enable = true;
      moonlight.enable = true;

      adb.enable = true;
      tor.enable = true;
      obs.enable = true;
      gimp.enable = true;
      easyeffects.enable = true;
      openrgb.enable = true;
      helix.enable = true;
    };

    services = {
      tailscale = {
        tags = [ "gaming" ];
      };
      mullvad.enable = true;

      restic = {
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
      wolf.enable = true;

      caddy.enable = true;

      syncthing = {
        devices = {
          pluto = {
            id = "J72PQBN-T4JUXSX-QPAGJ6K-SCFU4GS-CKLHRNJ-H3KW5YX-LRTT43Y-KGX2DQU";
          };
        };
        folders = {
          "${homeDir}/Documents/Wallets" = {
            id = "wallets";
            devices = [ "pluto" ];
          };
          "${homeDir}/Documents/Notes" = {
            id = "notes";
            devices = [ "pluto" ];
          };
        };
      };
    };

    system = {
      user = {
        sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBK67b6pvKUWVH/lflBvW7TI6DTXy7xT7iM8xpvHvbi0";
      };

      persistence = {
        userConfig.directories = [
          ".node-llama-cpp"
        ];
      };
    };
  };
}
