{ config, lib, ... }:
with lib;
let
  cfg = config.custom.apps.git;
in
{
  options.custom.apps.git = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    custom.system.home.extraOptions = {
      home.file.".ssh/allowed_signers".text = "* ${config.custom.system.user.sshPublicKey}";

      programs.git = {
        enable = true;
        settings = {
          user = {
            inherit (config.custom.system.user) email;
            name = config.custom.system.user.fullName;
            signingkey = config.custom.system.user.sshPublicKey;
          };
          gpg = {
            format = "ssh";
            ssh.allowedSignersFile = "~/.ssh/allowed_signers";
          };
          commit.gpgsign = true;
          user.init.defaultBranch = "main";
        };
      };
    };
  };
}
