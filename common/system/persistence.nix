{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.persistence;
in
{
  options.custom.system.persistence = {
    enable = custom.enableOption;

    config = mkOption {
      type = types.submodule {
        options = {
          directories = mkOption {
            type = types.listOf (
              types.either types.str (
                types.submodule {
                  options = {
                    directory = mkOption { type = types.str; };
                    user = mkOption {
                      type = types.str;
                      default = "root";
                    };
                    group = mkOption {
                      type = types.str;
                      default = "root";
                    };
                    mode = mkOption {
                      type = types.str;
                      default = "0755";
                    };
                  };
                }
              )
            );
            default = [ ];
          };
          files = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
        };
      };
      default = { };
    };

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
          };
          files = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
        };
      };
      default = { };
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
      ]
      ++ cfg.config.directories;
      files = [
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
      ]
      ++ cfg.config.files;
      users.${config.custom.system.user.name} = {
        inherit (cfg.userConfig) directories files;
      };
    };
  };
}
