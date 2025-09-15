{ inputs, vars, ... }:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager

    ../../common
  ];

  networking.hostName = "lab";

  custom = {
    inherit (vars) user;

    apps = {
      # cli
      yazi.enable = true;
      git.enable = true;
    };

    services = {
      tailscale.enable = true;
      openssh.enable = true;

      restic = {
        enable = true;
        frequency = "daily";
        repos = {
          borgbase = true;
        };
        paths = [
          "/fun/media/docs"
          "/fun/media/gallery"
        ];
      };

      caddy = {
        enable = true;
        domain = "f1nn.space";
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

      #minecraft.enable = true;

      open-webui.enable = true;

      i2pd.enable = true;

      forgejo.enable = true;

      monero = {
        enable = true;
        whitelist = [
          "100.127.231.5" # desktop
          "100.125.233.13" # phone
        ];
      };
      p2pool = {
        enable = true;

        # extra mining wallet
        # token for https://xmrvsbeast.com = 567340348
        wallet = "43dp8mYf4Jq6tNiKnbPvJNhd8xAhWrCyuGksFqTvmJXkdeDHstSRCRdGWzjLo2nCMwdHSp3sL1QewER2rNoYM7Kn5xFbZmy";
      };
    };

    system = {
      nix.enable = true;
      boot.enable = true;
      env.enable = true;
      locale.enable = true;
      packages.enable = true;
      xdg.enable = true;
      persistence.enable = true;
      sops.enable = true;
      security.enable = true;
      remoteUnlock.enable = true;
    };

    hardware = {
      gpu = {
        intel.enable = true;
      };
      network.enable = true;
    };
  };
}
