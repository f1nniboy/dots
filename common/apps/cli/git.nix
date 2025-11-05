{
  config,
  lib,
  vars,
  ...
}:
with lib;
let
  cfg = config.custom.apps.git;
in
{
  options.custom.apps.git = {
    enable = custom.enableOption;

    email = mkOption {
      type = types.str;
      default = vars.git.email;
    };
  };

  config = mkIf cfg.enable {
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
            inherit (cfg) email;
          };
          gpg.format = "ssh";
          commit.gpgsign = true;
          init.defaultBranch = "main";
        };
      };
    };
  };
}
