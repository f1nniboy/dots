{ lib, config, ... }:
with lib;
let
  serviceDomain = custom.mkServiceDomain config "multi-scrobbler";

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
        url = "https://${custom.mkServiceDomain config "jellyfin"}:443";
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
        redirectUri = "https://${serviceDomain}/callback";
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
        redirectUri = "https://${serviceDomain}/lastfm/callback";
      };
    }
  ];
}
