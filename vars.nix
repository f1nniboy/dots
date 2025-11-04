rec {
  user = {
    fullName = "Finn";
    nick = "finn";
    email = "me@${lab.domain}";
  };

  ssh = {
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBK67b6pvKUWVH/lflBvW7TI6DTXy7xT7iM8xpvHvbi0" # desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICT4w58tzgbdbaJ33zNkUrV0eRWY+e5B/FQejghLR6dh" # laptop
    ];
  };

  lab = {
    domain = "f1nn.space";
  };

  net = {
    hosts = {
      lab = "100.100.10.10";
      desktop = "100.100.20.20";
      laptop = "100.81.153.30";
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
