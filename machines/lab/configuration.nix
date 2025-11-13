{
  vars,
  ...
}:
{
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

    services = {
      openssh.enable = true;
      tailscale = {
        enable = true;
        tags = [ "server" ];
      };

      restic = {
        enable = true;
        frequency = "daily";
        repos = {
          borgbase = true;
        };
      };

      caddy = {
        enable = true;
        inherit (vars.net) domain;
      };
      acme = {
        enable = true;
      };

      postgresql.enable = true;
      redis.enable = true;
      docker.enable = true;

      vaultwarden.enable = true;

      arr.enable = true;
      sabnzbd.enable = true;
      jellyfin = {
        enable = true;
        id = "87ee8278880a4b8882e844dc58306a31";
        libraries = {
          Filme = {
            id = "7a2175bccb1f1a94152cbd2b2bae8f6d";
            type = "movies";
            path = "movies";
          };
          Serien = {
            id = "43cfe12fe7d9d8d21251e0964e0232e2";
            type = "tvshows";
            path = "shows";
          };
        };
      };
      jellyseerr.enable = true;
      fileflows.enable = true;
      pinchflat.enable = true;

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

      open-webui.enable = true;

      i2pd.enable = true;

      forgejo.enable = true;

      soju.enable = true;
      convoyeur.enable = true;

      monero = {
        enable = true;
        whitelist = with vars.net.hosts; [
          desktop
          laptop
        ];
      };
      p2pool = {
        enable = true;
        wallet = "43dp8mYf4Jq6tNiKnbPvJNhd8xAhWrCyuGksFqTvmJXkdeDHstSRCRdGWzjLo2nCMwdHSp3sL1QewER2rNoYM7Kn5xFbZmy";
      };
    };

    system = {
      remoteUnlock.enable = true;
      media.enable = true;
    };

    hardware = {
      gpu.intel.enable = true;
    };
  };
}
