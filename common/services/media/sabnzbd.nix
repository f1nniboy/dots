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
    enable = mkEnableOption "SABnzbd download client";

    port = mkOption {
      type = types.port;
      default = 8080;
    };

    dirs = mkOption {
      type = types.submodule {
        options = {
          incomplete = mkOption {
            type = types.str;
            default = "${config.custom.media.baseDir}/downloads/incomplete";
          };
          complete = mkOption {
            type = types.str;
            default = "${config.custom.media.baseDir}/downloads/complete";
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
              default = null;
              description = "Category name (null means '*').";
            };
            script = mkOption {
              type = types.str;
              default = "Default";
              description = "Script name for this category.";
            };
            dir = mkOption {
              type = types.str;
              default = "";
              description = "Directory for this category.";
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
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "unrar"
      ];

    services.sabnzbd = {
      enable = true;
      group = "media";
    };

    custom.services.caddy.hosts = {
      sabnzbd = {
        subdomain = "dl.media";
        target = ":${toString cfg.port}";
        import = [ "auth" ];
      };
    };

    systemd = {
      tmpfiles.settings."10-sabnzbd-config"."/var/lib/sabnzbd/sabnzbd.ini"."C+" = {
        user = "sabnzbd";
        group = "media";
        mode = "0700";
        argument = config.sops.templates.sabnzbd-config.path;
      };
    };

    sops = {
      templates.sabnzbd-config = {
        content = import ../config/sabnzbd.nix {
          inherit cfg config;
        };
        owner = "sabnzbd";
      };
      secrets = {
        "common/sabnzbd/api-key".owner = "sabnzbd";
        "common/sabnzbd/nzb-key".owner = "sabnzbd";
        "common/sabnzbd/server/host".owner = "sabnzbd";
        "common/sabnzbd/server/username".owner = "sabnzbd";
        "common/sabnzbd/server/password".owner = "sabnzbd";
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/sabnzbd";
          user = "sabnzbd";
          group = "media";
          mode = "0700";
        }
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dirs.incomplete} 0770 nobody media - -"
      "d ${cfg.dirs.complete}   0770 nobody media - -"
    ]
    ++ categoryTmpfiles;
  };
}
