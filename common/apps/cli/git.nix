{ config, lib, ... }:
with lib;
let
  cfg = config.custom.apps.git;

  # map each public key to an allowed_signers line
  toAllowedSignersLine = key: "* ${key}";

  # convert the array of keys to allowed_signers content
  allowedSignersContent =
    lib.concatMapStringsSep "\n" toAllowedSignersLine
      config.custom.system.ssh.authorizedKeys;
in
{
  options.custom.apps.git = {
    enable = mkEnableOption "git config";
  };

  config = mkIf cfg.enable {
    custom.system.home.extraOptions = {
      home.file.".ssh/allowed_signers".text = allowedSignersContent;

      programs.git = {
        enable = true;
        userName = config.custom.system.user.fullName;
        userEmail = config.custom.system.user.email;
        extraConfig = {
          commit.gpgsign = true;
          gpg.format = "ssh";
          gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
          user.signingkey = config.custom.system.user.sshPublicKey;
          init.defaultBranch = "main";
        };
      };
    };
  };
}
