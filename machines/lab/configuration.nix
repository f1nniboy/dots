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

    ../../common
  ];

  custom = {
    presets = {
      base.enable = true;
    };

    apps = {
      # cli
      neovim.enable = true;
      yazi.enable = true;
      git.enable = true;
    };

    # for jellyfin, *arr, etc.
    media.enable = true;

    services = {
      tailscale.enable = true;
      openssh.enable = true;

      restic = {
        enable = true;
        frequency = "daily";
        repos = {
          borgbase = true;
        };
      };

      caddy = {
        enable = true;
        domain = "f1nn.space";
      };
      acme = {
        enable = true;
        domains = {
          "irc.${config.custom.services.caddy.domain}" = {
            group = "soju";
          };
        };
      };

      postgresql.enable = true;
      redis.enable = true;
      docker.enable = true;

      authelia.enable = true;
      lldap.enable = true;
      vaultwarden.enable = true;

      arr.enable = true;
      sabnzbd.enable = true;
      jellyfin = {
        enable = true;
        id = "2b5e889ac3bc4a228e0789ed5c5020f0";
      };
      jellyseerr.enable = true;
      fileflows.enable = true;
      pinchflat.enable = true;
      #piped.enable = true;

      immich.enable = true;
      samba.enable = true;
      miniflux.enable = true;
      notesnook.enable = true;
      radicale.enable = true;
      #karakeep.enable = true;

      paperless.enable = true;
      paperless-gpt.enable = true;

      muse.enable = true;
      multi-scrobbler.enable = true;
      #tidarr.enable = true;

      open-webui.enable = true;

      i2pd.enable = true;

      forgejo.enable = true;

      soju.enable = true;
      convoyeur.enable = true;

      monero = {
        enable = true;
        whitelist = [
          "100.100.20.20" # desktop
          "100.81.153.30" # laptop
        ];
      };
      p2pool = {
        enable = true;
        wallet = "43dp8mYf4Jq6tNiKnbPvJNhd8xAhWrCyuGksFqTvmJXkdeDHstSRCRdGWzjLo2nCMwdHSp3sL1QewER2rNoYM7Kn5xFbZmy";
      };
      xmrig = {
        enable = false;
        host = "127.0.0.1";
        cpuUsage = 30;
      };
    };

    system = {
      user = {
        fullName = "Finn";
        email = "me@f1nn.space";
      };
      inherit (vars) ssh;

      remoteUnlock.enable = true;
    };

    hardware = {
      gpu.intel.enable = true;
    };
  };
}
