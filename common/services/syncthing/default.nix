{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.syncthing;
  homeDir = config.custom.system.home.dir;

  mkFolder =
    _: folder:
    folder
    // {
      autoAcceptFolders = true;
      versioning = {
        type = "simple";
        params = {
          keep = "10";
          cleanoutDays = "0";
        };
      };
    };
in
{
  options.custom.services.syncthing = {
    enable = custom.enableOption;

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
      user = config.custom.system.user.name;
      inherit (config.users.users."${config.custom.system.user.name}") group;
      configDir = "${homeDir}/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        options = {
          urAccepted = -1;
        };
        inherit (cfg) devices;
        folders = mapAttrs mkFolder cfg.folders;
      };
    };

    custom.system.persistence.userConfig = {
      directories = [ ".config/syncthing" ];
    };
  };
}
