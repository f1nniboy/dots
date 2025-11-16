{
  config,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.system.sops;
in
{
  options.custom.system.sops = {
    enable = custom.enableOption;

    secrets = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            path = mkOption {
              type = types.str;
            };
            owner = mkOption {
              type = types.str;
              default = "root";
              description = "user which uses this secret";
            };
            source = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "which file to source the secret from";
            };
            forUsers = mkOption {
              type = types.bool;
              default = false;
              description = "whether this secret is used for users (password)";
            };
          };
        }
      );
      default = { };
    };
  };

  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = ./../../secrets/hosts/${config.networking.hostName}.yaml;
      age.sshKeyPaths = [ "/nix/secret/initrd/ssh_host_ed25519_key" ];

      # ref: https://github.com/Mic92/sops-nix/issues/427
      gnupg.sshKeyPaths = [ ];

      secrets = listToAttrs (
        map (
          value:
          let
            inherit (value) path;
            inherit (value) owner;
            inherit (value) source;
            inherit (value) forUsers;
            keyName = custom.mkSecretString path owner;
          in
          nameValuePair keyName {
            key = path;
            owner = mkIf (!forUsers) owner;
            sopsFile = mkIf (source != null) ./../../secrets/${source}.yaml;
            neededForUsers = forUsers;
          }
        ) cfg.secrets
      );
    };

    custom.system.persistence.userConfig = {
      directories = [ ".config/sops" ];
    };
  };
}
