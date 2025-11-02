{ lib, config, ... }:
with lib;
let
  serviceDomain = custom.mkServiceDomain config "multi-scrobbler";

  mkSecret =
    type: client: path:
    custom.mkSecretPlaceholder config "multi-scrobbler/${type}/${client}/${path}" "multi-scrobbler";
in
builtins.toJSON {
  sources = [
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
