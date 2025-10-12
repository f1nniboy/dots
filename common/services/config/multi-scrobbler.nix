{ config, ... }:
let
  mkSecret =
    type: client: path:
    config.sops.placeholder."${config.networking.hostName}/multi-scrobbler/${type}/${client}/${path}";
in
builtins.toJSON {
  sources = [
    {
      name = "Jellyfin";
      type = "jellyfin";
      enable = true;
      data = {
        url = "https://${config.custom.services.caddy.hosts.jellyfin.subdomain}.${config.custom.services.caddy.domain}:443";
        user = mkSecret "sources" "jellyfin" "user";
        apiKey =
          config.sops.placeholder."multi-scrobbler-${config.networking.hostName}/jellyfin/api-keys/multi-scrobbler";
      };
    }
    {
      name = "Spotify";
      type = "spotify";
      enable = true;
      data = {
        clientId = mkSecret "sources" "spotify" "client-id";
        clientSecret = mkSecret "sources" "spotify" "client-secret";
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
        token = mkSecret "clients" "listenbrainz" "token";
        username = mkSecret "clients" "listenbrainz" "username";
      };
    }
    {
      name = "last.fm (Client)";
      type = "lastfm";
      configureAs = "client";
      enable = true;
      data = {
        apiKey = mkSecret "clients" "lastfm" "api-key";
        secret = mkSecret "clients" "lastfm" "secret";
        redirectUri = "https://${config.custom.services.caddy.hosts.multi-scrobbler.subdomain}.${config.custom.services.caddy.domain}/lastfm/callback";
      };
    }
  ];
}
