{
  options,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.system.home;
in
{
  options.custom.system.home = {
    enable = custom.enableOption;
    homeFiles = mkOption {
      type = types.attrs;
      default = { };
      description = "alias for home.file";
    };
    configFiles = mkOption {
      type = types.attrs;
      default = { };
      description = "alias for xdg.configFile";
    };
    extraOptions = mkOption {
      type = types.attrs;
      default = { };
    };
    dir = mkOption {
      type = types.str;
      default = config.users.users."${config.custom.system.user.name}".home;
    };
  };

  config = mkIf cfg.enable {
    custom.system.home = {
      configFiles = {
        # ref: https://github.com/nix-community/home-manager/issues/1213
        "mimeapps.list".force = true;
      };
      extraOptions = {
        home = {
          inherit (config.system) stateVersion;
          file = cfg.homeFiles;
        };
        xdg = {
          enable = true;
          configFile = cfg.configFiles;
        };
        systemd.user.startServices = "sd-switch";
      };
    };

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;

      users.${config.custom.system.user.name} =
        mkAliasDefinitions options.custom.system.home.extraOptions;
    };
  };
}
