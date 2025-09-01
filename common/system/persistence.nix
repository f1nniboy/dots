{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.persistence;
in
{
  options.custom.system.persistence = {
    enable = mkEnableOption "persistent storage";
    userConfig = mkOption {
      type = types.submodule {
        options = {
          directories = mkOption {
            type = types.listOf (
              types.either types.str (
                types.submodule {
                  options = {
                    directory = mkOption { type = types.str; };
                    mode = mkOption {
                      type = types.str;
                      default = "0755";
                    };
                  };
                }
              )
            );
            default = [ ];
            description = "User directories to persist";
          };
          files = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "User files to persist";
          };
        };
      };
      default = { };
      description = "Persistent storage for the user";
    };
  };

  config = mkIf cfg.enable {
    environment.persistence."/nix/persist" = {
      hideMounts = true;
      directories = [
        {
          directory = "/tmp";
          mode = "1777";
        }
        "/var/log"
        "/var/lib/nixos"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
      ];
      users.${config.custom.user.name} = {
        inherit (cfg.userConfig) directories files;
      };
    };
  };
}
