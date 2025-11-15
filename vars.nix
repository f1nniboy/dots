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
      diana = "100.64.0.6"; # desktop
      pluto = "100.64.0.16"; # laptop

      jupiter = "100.64.0.8"; # vps
      apollo = "100.64.0.9"; # lab
    };
    services = {
      lldap = hosts.jupiter;
      p2pool = hosts.apollo;
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
