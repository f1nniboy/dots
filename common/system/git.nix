{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.system.git;
in
{
  options.custom.system.git = {
    user = mkOption {
      type = types.submodule {
        options = {
          enable = custom.enableOption;
        };
      };
    };

    server = mkOption {
      type = types.submodule {
        options = {
          enable = custom.enableOption;

          repoDir = mkOption {
            type = types.str;
            default = "/fun/srv/git";
          };
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.user.enable {
      custom.system.home.extraOptions = {
        programs.git = {
          enable = true;
          signing = {
            key = config.custom.system.user.sshPublicKey;
            signByDefault = true;
          };
          settings = {
            user = {
              name = config.custom.system.user.fullName;
              inherit (config.custom.system.user) email;
            };
            gpg.format = "ssh";
            commit.gpgsign = true;
            init.defaultBranch = "main";
          };
        };
      };
    })

    (mkIf cfg.server.enable {
      environment.systemPackages = [
        pkgs.git
      ];

      users = {
        users.git = {
          isNormalUser = true;
          group = "git";
          createHome = true;
          home = cfg.server.repoDir;
          shell = "${pkgs.git}/bin/git-shell";
          openssh.authorizedKeys.keys = config.custom.system.ssh.authorizedKeys;
        };
        groups.git = { };
      };

      custom.services = {
        restic.paths = [
          cfg.server.repoDir
        ];
      };
    })
  ];
}
