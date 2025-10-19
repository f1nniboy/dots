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
        settings = {
          user = {
            name = config.custom.system.user.fullName;
            email = config.custom.system.user.email;
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
