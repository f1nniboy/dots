rec {
  user = {
    fullName = "Finn";
    nick = "finn";
    email = "me@${net.domain}";
  };

  ssh = {
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBK67b6pvKUWVH/lflBvW7TI6DTXy7xT7iM8xpvHvbi0" # desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICT4w58tzgbdbaJ33zNkUrV0eRWY+e5B/FQejghLR6dh" # laptop
    ];
  };

  net = rec {
    domain = "f1nn.space";
    hosts = {
      desktop = "100.64.0.6";
      laptop = "100.64.0.16";

      lab = "100.64.0.9";
      vps = "100.64.0.8";
    };
    services = {
      lldap = hosts.lab;
      p2pool = hosts.lab;
    };
  };

  # TODO: reduce docker usage
  docker = {
    images = {
      "revenz/fileflows" = "latest";
      "foxxmd/multi-scrobbler" = "latest";
      "dovah/muse" = "latest";
      "mongo" = "latest";
      "icereed/paperless-gpt" = "latest";

      "ghcr.io/games-on-whales/wolf" = "wolf-ui";
      "ghcr.io/games-on-whales/wolfmanager/wolfmanager" = "latest";

      "streetwriters/notesnook-sync" = "latest";
      "streetwriters/identity" = "latest";
      "streetwriters/monograph" = "latest";
      "streetwriters/sse" = "latest";

      "minio/minio" = "latest";
      "minio/mc" = "latest";
    };
  };
}
