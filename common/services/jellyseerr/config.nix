{ lib, config, ... }:
let
  mkAppSecret = path: config.sops.placeholder."${config.networking.hostName}/jellyseerr/${path}";
in
with lib;
builtins.toJSON {
  clientId = mkAppSecret "client-id";
  vapidPrivate = mkAppSecret "vapid/private";
  vapidPublic = mkAppSecret "vapid/public";
  main = {
    apiKey = mkAppSecret "api-key";
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
    externalHostname = "https://${custom.mkServiceDomain config "jellyfin"}";
    jellyfinForgotPasswordUrl = "";
    libraries = with config.custom.services.jellyfin; [
      {
        id = libraries.Filme.id;
        name = "Filme";
        enabled = true;
        type = "movie";
      }
      {
        id = libraries.Serien.id;
        name = "Serien";
        enabled = true;
        type = "show";
      }
    ];
    serverId = config.custom.services.jellyfin.id;
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
      activeDirectory = "${config.custom.system.media.baseDir}/library/movies";
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
      activeDirectory = "${config.custom.system.media.baseDir}/library/shows";
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
