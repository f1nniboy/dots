{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.sabnzbd;

  categoryTmpfiles =
    let
      catLines = map (
        cat: if cat.dir != "" then "d ${cfg.dirs.complete}/${cat.dir} 0770 nobody media - -" else null
      ) cfg.categories;
    in
    filter (line: line != null) catLines;
in
{
  options.custom.services.sabnzbd = {
    enable = custom.enableOption;

    port = mkOption {
      type = types.port;
      default = 8080;
    };

    dirs = mkOption {
      type = types.submodule {
        options = {
          incomplete = mkOption {
            type = types.str;
            default = "${config.custom.system.media.baseDir}/downloads/incomplete";
          };
          complete = mkOption {
            type = types.str;
            default = "${config.custom.system.media.baseDir}/downloads/complete";
          };
        };
      };
      default = { };
    };

    categories = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.nullOr types.str;
              default = null; # null = "*"
            };
            script = mkOption {
              type = types.str;
              default = "Default";
            };
            dir = mkOption {
              type = types.str;
              default = "";
            };
          };
        }
      );
      default = [
        {
          name = null;
          script = "None";
          dir = "";
        }
        {
          name = "movies";
          script = "Default";
          dir = "movies";
        }
        {
          name = "tv";
          script = "Default";
          dir = "shows";
        }
      ];
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      { assertion = config.custom.system.media.enable; }
    ];

    services.sabnzbd = {
      enable = true;
      group = "media";
    };

    systemd = {
      tmpfiles.settings."10-sabnzbd-config"."/var/lib/sabnzbd/sabnzbd.ini"."C+" = {
        user = "sabnzbd";
        group = "media";
        mode = "0600";
        argument = config.sops.templates.sabnzbd-config.path;
      };
    };

    sops = {
      templates.sabnzbd-config = {
        content = import ./config.nix {
          inherit lib cfg config;
        };
        owner = "sabnzbd";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dirs.incomplete} 0770 nobody media - -"
      "d ${cfg.dirs.complete}   0770 nobody media - -"
    ]
    ++ categoryTmpfiles;

    custom = {
      system.sops.secrets = [
        {
          path = "sabnzbd/api-key";
          owner = "sabnzbd";
        }
        {
          path = "sabnzbd/nzb-key";
          owner = "sabnzbd";
        }
        {
          path = "sabnzbd/server/host";
          owner = "sabnzbd";
        }
        {
          path = "sabnzbd/server/username";
          owner = "sabnzbd";
        }
        {
          path = "sabnzbd/server/password";
          owner = "sabnzbd";
        }
      ];
      services.caddy.hosts = {
        sabnzbd = {
          target = ":${toString cfg.port}";
          import = [ "auth" ];
        };
      };

      system = {
        packages.unfreePackages = [
          "unrar"
        ];

        persistence.config = {
          directories = [
            {
              directory = "/var/lib/sabnzbd";
              user = "sabnzbd";
              group = "media";
              mode = "0700";
            }
          ];
        };
      };
    };
  };
}
