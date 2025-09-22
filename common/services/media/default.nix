let
  baseDir = "/fun/media/htpc";
in
{
  imports = [
    ./arr.nix
    ./fileflows.nix
    ./jellyfin.nix
    ./jellyseerr.nix
    ./pinchflat.nix
    ./sabnzbd.nix
  ];

  users = {
    users.media = {
      group = "media";
      isSystemUser = true;
    };
    groups.media = {
      gid = 981;
    };
  };

  systemd.tmpfiles.rules = [
    "d ${baseDir}                           	0770 nobody			media     - -"

    "d ${baseDir}/library/movies							0770 nobody			media     - -"
    "d ${baseDir}/library/shows  							0770 nobody			media     - -"
    "d ${baseDir}/library/music  							0770 nobody			media     - -"
    "d ${baseDir}/library/archive							0770 pinchflat	pinchflat - -"

    "d ${baseDir}/downloads/incomplete      	0770 nobody			media     - -"

    "d ${baseDir}/downloads/complete/movies		0770 nobody			media     - -"
    "d ${baseDir}/downloads/complete/shows  	0770 nobody			media     - -"

    "d ${baseDir}/downloads/converted/movies	0770 fileflows	media     - -"
    "d ${baseDir}/downloads/converted/shows  	0770 fileflows	media     - -"
  ];
}
