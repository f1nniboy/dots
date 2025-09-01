{ config, ... }:
''
  {
   "clientId": "",
   "vapidPrivate": "",
   "vapidPublic": "",
   "main": {
  	"apiKey": "${config.sops.placeholder."${config.networking.hostName}/jellyseerr/api-key"}",
  	"applicationTitle": "Jellyseerr",
  	"cacheImages": true,
  	"defaultPermissions": 67117216,
  	"localLogin": false,
  	"discoverRegion": "DE",
  	"streamingRegion": "DE",
  	"mediaServerType": 2,
  	"locale": "de"
   },
   "jellyfin": {
  	"name": "Jellyfin",
  	"ip": "localhost",
  	"port": 8096,
  	"useSsl": false,
  	"urlBase": "",
  	"externalHostname": "https://media.${config.custom.services.caddy.domain}",
  	"jellyfinForgotPasswordUrl": "",
  	"libraries": [],
  	"serverId": "${config.sops.placeholder."jellyseerr-${config.networking.hostName}/jellyfin/server-id"}",
  	"apiKey": "${config.sops.placeholder."jellyseerr-${config.networking.hostName}/jellyfin/api-keys/jellyseerr"}"
   },
   "radarr": [
  	{
  	 "name": "Radarr",
  	 "hostname": "localhost",
  	 "port": 7878,
  	 "apiKey": "${config.sops.placeholder."jellyseerr-${config.networking.hostName}/radarr/api-key"}",
  	 "activeProfileId": 9,
  	 "activeProfileName": "HD",
  	 "activeDirectory": "/fun/media/htpc/library/movies",
  	 "isDefault": true,
  	 "externalUrl": "https://mov.media.${config.custom.services.caddy.domain}",
  	 "id": 0
  	}
   ],
   "sonarr": [
  	{
  	 "name": "Sonarr",
  	 "hostname": "localhost",
  	 "port": 8989,
  	 "apiKey": "${config.sops.placeholder."jellyseerr-${config.networking.hostName}/sonarr/api-key"}",
  	 "activeProfileId": 9,
  	 "activeProfileName": "HD",
  	 "activeDirectory": "/fun/media/htpc/library/shows",
  	 "isDefault": true,
  	 "enableSeasonFolders": true,
  	 "externalUrl": "https://tv.media.${config.custom.services.caddy.domain}",
  	 "id": 0
  	}
   ],
   "public": {
  	"initialized": true
   }
  }
''
