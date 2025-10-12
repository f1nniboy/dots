{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.syncthing;
  homeDir = config.custom.system.home.dir;
in
{
  options.custom.services.syncthing = {
    enable = mkEnableOption "Decentralized file syncing";

    devices = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            id = mkOption {
              type = types.str;
            };
          };
        }
      );
      default = { };
    };

    folders = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            id = mkOption {
              type = types.str;
            };
            devices = mkOption {
              type = types.listOf types.str;
            };
          };
        }
      );
      default = { };
    };
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      group = config.users.users."${config.custom.system.user.name}".group;
      user = config.custom.system.user.name;
      configDir = "${homeDir}/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        inherit (cfg) devices folders;
      };
    };
  };
}
