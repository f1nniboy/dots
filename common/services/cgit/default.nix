{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.cgit;

  cgitrcLine =
    name: value:
    "${name}=${
      if value == true then
        "1"
      else if value == false then
        "0"
      else
        toString value
    }";

  # list value as multiple lines (for "readme" for example)
  cgitrcEntry =
    name: value: if isList value then map (cgitrcLine name) value else [ (cgitrcLine name value) ];

  rcFile = pkgs.writeText "cgitrc" ''
    # global
    ${concatStringsSep "\n" (flatten (mapAttrsToList cgitrcEntry cfg.settings))}

    # repos
    ${concatStringsSep "\n" (
      flatten (
        mapAttrsToList (
          sectionName: repos:
          [ "section=${sectionName}" ]
          ++ mapAttrsToList (
            repoName: repo:
            flatten [
              "repo.url=${repoName}"
              "repo.path=${config.custom.system.git.server.repoDir}/${repo.path}"
              "repo.desc=${repo.desc}"
            ]
          ) repos
        ) cfg.repos
      )
    )}
  '';

  serviceDomain = custom.mkServiceDomain config "cgit";

  assetsPath = "/static";
  theme = inputs.cgit-theme;

  repoType = types.submodule (
    { name, ... }:
    {
      options = {
        desc = mkOption {
          type = types.str;
        };
        path = mkOption {
          type = types.str;
          default = name;
        };
      };
    }
  );
in
{
  options.custom.services.cgit = {
    enable = custom.enableOption;

    user = mkOption {
      type = types.str;
      default = "git";
    };

    group = mkOption {
      type = types.str;
      default = "git";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.cgit;
    };

    repos = mkOption {
      type = types.attrsOf (types.attrsOf repoType);
      default = {

        personal = {
          dots = {
            desc = "my personal NixOS flake";
          };
          blog = {
            desc = "my personal blog";
          };
          cgit-theme = {
            desc = "my cgit forge theme";
          };
        };
        ampere = {
          "ampere/bot" = {
            desc = "Discord bot of Ampere";
            path = "ampere/bot";
          };
          "ampere/api" = {
            desc = "API behind Ampere";
            path = "ampere/api";
          };
        };
        other = {
          llog = {
            desc = "a Discord bot that acts like a human";
          };
        };
        archive = {
          slash = {
            desc = "KISS-like package manager";
          };
          selfcord = {
            desc = "Discord self-bot, written in Java";
          };
        };
      };
    };

    settings = mkOption {
      type = types.attrs;
      default = {
        root-title = "f1nn's forge";
        root-desc = "why are you here?";

        css = "${assetsPath}/cgit.css";
        favicon = "";
        logo = "";

        enable-index-owner = 0;
        enable-commit-graph = true;
        enable-follow-links = true;
        enable-http-clone = 0;

        readme = [
          "main:README.md"
          "master:README.md"
        ];

        source-filter = "${cfg.package}/lib/cgit/filters/syntax-highlighting.py";
        about-filter = "${cfg.package}/lib/cgit/filters/about-formatting.sh";

        clone-url = "https://${serviceDomain}/$CGIT_REPO_URL git@${serviceDomain}:$CGIT_REPO_URL";
        snapshots = "tar.gz tar.bz2 zip";

        "mimetype.gif" = "image/gif";
        "mimetype.html" = "text/html";
        "mimetype.jpg" = "image/jpeg";
        "mimetype.jpeg" = "image/jpeg";
        "mimetype.pdf" = "application/pdf";
        "mimetype.png" = "image/png";
        "mimetype.svg" = "image/svg+xml";
      };
    };
  };

  config = mkIf cfg.enable {
    services.fcgiwrap.instances = {
      cgit = {
        process = { inherit (cfg) user group; };
        socket = { inherit (config.services.caddy) user group; };
      };
      git = {
        process = {
          user = "git";
          group = "git";
        };
        socket = { inherit (config.services.caddy) user group; };
      };
    };

    systemd.services.fcgiwrap-cgit = {
      path = [
        pkgs.python3
        pkgs.python3Packages.pygments
      ];
    };

    custom.services = {
      caddy.hosts = {
        cgit = {
          type = "custom";
          target = null;
          # ref: https://www.jamesatkins.com/posts/git-over-http-with-caddy
          extra = ''
            @git_cgi path_regexp "^.*/(HEAD|info/refs|objects/info/[^/]+|git-upload-pack)$"
            @git_static path_regexp "^.*/objects/([0-9a-f]{2}/[0-9a-f]{38}|pack/pack-[0-9a-f]{40}\.(pack|idx))$"

            handle @git_cgi {
              reverse_proxy unix/${config.services.fcgiwrap.instances.git.socket.address} {
                transport fastcgi {
                  env SCRIPT_FILENAME ${pkgs.git}/libexec/git-core/git-http-backend
                  env GIT_PROJECT_ROOT ${config.custom.system.git.server.repoDir}
                  env GIT_HTTP_EXPORT_ALL 1
                }
              }
            }

            handle @git_static {
              file_server {
                root ${config.custom.system.git.server.repoDir}
              }
            }

            handle_path ${assetsPath}/* {
              root * ${theme}
              file_server
            }

            handle {
              reverse_proxy unix/${config.services.fcgiwrap.instances.cgit.socket.address} {
                transport fastcgi {
                  env DOCUMENT_ROOT ${cfg.package}/cgit/
                  env SCRIPT_FILENAME ${cfg.package}/cgit/cgit.cgi
                  env CGIT_CONFIG ${rcFile}
                }
              }
            }
          '';
        };
      };
    };
  };
}
