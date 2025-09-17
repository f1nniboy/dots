{ config, ... }:
builtins.toJSON {
  sources = [
    {
      name = "Jellyfin";
      enable = true;
      data = {
        url = "https://${config.custom.services.caddy.hosts.jellyfin.subdomain}.${config.custom.services.caddy.domain}:443";
        user = config.sops.placeholder."${config.networking.hostName}/multi-scrobbler/sources/jellyfin/user";
        apiKey = config.sops.placeholder."multi-scrobbler-${config.networking.hostName}/jellyfin/api-keys/multi-scrobbler";
      };
    }
    {
      name = "Spotify";
      enable = true;
      data = {
        clientId = config.sops.placeholder."${config.networking.hostName}/multi-scrobbler/sources/spotify/client-id";
        clientSecret = config.sops.placeholder."${config.networking.hostName}/multi-scrobbler/sources/spotify/client-secret";
        redirectUri = "https://${config.custom.services.caddy.hosts.multi-scrobbler.subdomain}.${config.custom.services.caddy.domain}/callback";
      };
    }
  ];
  clients = [
    {
      name = "ListenBrainz (Client)";
      type = "listenbrainz";
      configureAs = "client";
      enable = true;
      data = {
        token = config.sops.placeholder."${config.networking.hostName}/multi-scrobbler/clients/listenbrainz/token";
        username = config.sops.placeholder."${config.networking.hostName}/multi-scrobbler/clients/listenbrainz/username";
      };
    }
    {
      name = "last.fm (Client)";
      type = "lastfm";
      configureAs = "client";
      enable = true;
      data = {
        apiKey = config.sops.placeholder."${config.networking.hostName}/multi-scrobbler/clients/lastfm/api-key";
        secret = config.sops.placeholder."${config.networking.hostName}/multi-scrobbler/clients/lastfm/secret";
        redirectUri = "https://${config.custom.services.caddy.hosts.multi-scrobbler.subdomain}.${config.custom.services.caddy.domain}/lastfm/callback";
      };
    }
  ];
}