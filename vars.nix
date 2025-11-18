rec {
  user = {
    fullName = "Finn";
    nick = "finn";
    email = "me@${domains.public}";
  };

  ssh = {
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBK67b6pvKUWVH/lflBvW7TI6DTXy7xT7iM8xpvHvbi0" # diana
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICT4w58tzgbdbaJ33zNkUrV0eRWY+e5B/FQejghLR6dh" # pluto
    ];
  };

  domains = {
    public = "f1nn.space";
    local = "net.lan";
  };

  hosts = {
    diana = "100.64.0.6"; # desktop
    pluto = "100.64.0.16"; # laptop

    jupiter = "100.64.0.8"; # vps
    apollo = "100.64.0.9"; # lab
  };

  services = rec {
    # expose these services at `${sub}.${domains.local}`
    ## apollo (set as default in common/config.nix)
    vaultwarden.sub = "vault";
    forgejo.sub = "code";
    i2pd.sub = "i2p";
    miniflux.sub = "news";
    immich.sub = "photo";
    monero.sub = "xmr";
    multi-scrobbler.sub = "scrobble";
    open-webui.sub = "chat";
    soju.sub = "irc";
    p2pool.sub = "p2pool";
    radicale.sub = "cal";
    karakeep.sub = "keep";

    jellyfin.sub = "media";
    fileflows.sub = "flows.${jellyfin.sub}";
    jellyseerr.sub = "search.${jellyfin.sub}";
    pinchflat.sub = "archive.${jellyfin.sub}";
    prowlarr.sub = "idx.${jellyfin.sub}";
    radarr.sub = "mov.${jellyfin.sub}";
    sonarr.sub = "tv.${jellyfin.sub}";
    sabnzbd.sub = "dl.${jellyfin.sub}";

    notesnook.sub = "note";
    notesnook-api.sub = "api.${notesnook.sub}";
    notesnook-auth.sub = "auth.${notesnook.sub}";
    notesnook-sse.sub = "sse.${notesnook.sub}";
    notesnook-mono.sub = "mono.${notesnook.sub}";
    notesnook-s3.sub = "files.${notesnook.sub}";

    paperless.sub = "paper";
    paperless-gpt.sub = "ai.${paperless.sub}";

    ## diana
    wolf = {
      sub = "wolf";
      host = "diana";
    };

    # expose these services at `${sub}.${domains.public}`
    ## jupiter
    blog = {
      sub = null;
      public = true;
    };
    authelia-public = {
      sub = "auth";
      public = true;
    };
    authelia = {
      sub = "auth";
      host = "jupiter";
    };
    headscale = {
      sub = "net";
      public = true;
    };
    lldap = {
      sub = "ldap";
      public = true;
    };
    step-ca = {
      sub = "ca";
      public = true;
    };
  };

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
