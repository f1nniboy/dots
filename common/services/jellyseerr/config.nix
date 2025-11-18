{ lib, config, ... }:
with lib;
let
  mkSecret = path: custom.mkSecretPlaceholder config "jellyseerr/${path}" "jellyseerr";
in
{
  clientId = mkSecret "client-id";
  vapidPrivate = mkSecret "vapid/private";
  vapidPublic = mkSecret "vapid/public";
  main = {
    apiKey = mkSecret "api-key";
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
        inherit (libraries.Filme) id;
        name = "Filme";
        enabled = true;
        type = "movie";
      }
      {
        inherit (libraries.Serien) id;
        name = "Serien";
        enabled = true;
        type = "show";
      }
    ];
    serverId = config.custom.services.jellyfin.id;
    apiKey = custom.mkSecretPlaceholder config "jellyfin/api-keys/jellyseerr" "jellyseerr";
  };
  radarr = [
    {
      name = "Radarr";
      hostname = "localhost";
      port = 7878;
      apiKey = custom.mkSecretPlaceholder config "radarr/api-key" "jellyseerr";
      useSsl = false;
      activeProfileId = 11;
      activeProfileName = "HD";
      activeDirectory = "${config.custom.system.media.baseDir}/library/movies";
      is4k = false;
      minimumAvailability = "released";
      tags = [ ];
      isDefault = true;
      externalUrl = "https://${custom.mkServiceDomain config "radarr"}";
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
      apiKey = custom.mkSecretPlaceholder config "sonarr/api-key" "jellyseerr";
      useSsl = false;
      activeProfileId = 11;
      activeProfileName = "HD";
      activeDirectory = "${config.custom.system.media.baseDir}/library/shows";
      tags = [ ];
      animeTags = [ ];
      is4k = false;
      isDefault = true;
      enableSeasonFolders = true;
      externalUrl = "https://${custom.mkServiceDomain config "sonarr"}";
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
