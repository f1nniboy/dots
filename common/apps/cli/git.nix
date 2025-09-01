{ config, lib, ... }:
with lib;
let
  cfg = config.custom.apps.git;
in
{
  options.custom.apps.git = {
    enable = mkEnableOption "git config";
  };

  config = mkIf cfg.enable {
    custom.system.home.extraOptions = {
      home.file.".ssh/allowed_signers".text = "* ${config.custom.user.sshPublicKey}";

      programs.git = {
        enable = true;
        userName = config.custom.user.fullName;
        userEmail = config.custom.user.email;
        extraConfig = {
          commit.gpgsign = true;
          gpg.format = "ssh";
          gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
          user.signingkey = config.custom.user.sshPublicKey;
          init.defaultBranch = "main";
        };
      };
    };
  };
}
