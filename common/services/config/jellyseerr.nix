{ config, ... }:
let
  libraryIds = {
    Filme = "7a2175bccb1f1a94152cbd2b2bae8f6d";
    Serien = "43cfe12fe7d9d8d21251e0964e0232e2";
  };
in
builtins.toJSON {
  clientId = config.sops.placeholder."${config.networking.hostName}/jellyseerr/client-id";
  vapidPrivate = config.sops.placeholder."${config.networking.hostName}/jellyseerr/vapid/private";
  vapidPublic = config.sops.placeholder."${config.networking.hostName}/jellyseerr/vapid/public";
  main = {
    apiKey = config.sops.placeholder."${config.networking.hostName}/jellyseerr/api-key";
    applicationTitle = "Jellyseerr";
    applicationUrl = "";
    cacheImages = true;
    defaultPermissions = 67117216;
    mediaServerLogin = true;
    discoverRegion = "DE";
    streamingRegion = "DE";
    originalLanguage = "";
    mediaServerType = 2;
    partialRequestsEnabled = true;
    locale = "de";
  };
  jellyfin = {
    name = "Jellyfin";
    ip = "localhost";
    port = 8096;
    useSsl = false;
    urlBase = "";
    externalHostname = "https://media.${config.custom.services.caddy.domain}";
    jellyfinForgotPasswordUrl = "";
    libraries = [
      {
        id = libraryIds.Filme;
        name = "Filme";
        enabled = true;
        type = "movie";
      }
      {
        id = libraryIds.Serien;
        name = "Serien";
        enabled = true;
        type = "show";
      }
    ];
    serverId = config.sops.placeholder."jellyseerr-${config.networking.hostName}/jellyfin/server-id";
    apiKey =
      config.sops.placeholder."jellyseerr-${config.networking.hostName}/jellyfin/api-keys/jellyseerr";
  };
  radarr = [
    {
      name = "Radarr";
      hostname = "localhost";
      port = 7878;
      apiKey = config.sops.placeholder."jellyseerr-${config.networking.hostName}/radarr/api-key";
      useSsl = false;
      activeProfileId = 11;
      activeProfileName = "HD";
      activeDirectory = "${config.custom.media.baseDir}/library/movies";
      is4k = false;
      minimumAvailability = "released";
      tags = [ ];
      isDefault = true;
      externalUrl = "https://mov.media.${config.custom.services.caddy.domain}";
      syncEnabled = true;
      preventSearch = false;
      tagRequests = false;
      id = 0;
    }
  ];
  sonarr = [
    {
      name = "Sonarr";
      hostname = "localhost";
      port = 8989;
      apiKey = config.sops.placeholder."jellyseerr-${config.networking.hostName}/sonarr/api-key";
      useSsl = false;
      activeProfileId = 11;
      activeProfileName = "HD";
      activeDirectory = "${config.custom.media.baseDir}/library/shows";
      tags = [ ];
      animeTags = [ ];
      is4k = false;
      isDefault = true;
      enableSeasonFolders = true;
      externalUrl = "https://tv.media.${config.custom.services.caddy.domain}";
      syncEnabled = true;
      preventSearch = false;
      tagRequests = false;
      id = 0;
    }
  ];
  public = {
    initialized = true;
  };
}
