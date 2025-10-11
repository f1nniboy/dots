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
    enable = mkEnableOption "home-manager configuration";
    file = mkOption {
      type = types.attrs;
      default = { };
      description = "Files to manage with home-manager home.file";
    };
    configFile = mkOption {
      type = types.attrs;
      default = { };
      description = "Files to manage with home-manager xdg.configFile";
    };
    extraOptions = mkOption {
      type = types.attrs;
      default = { };
      description = "Additional home-manager options";
    };
  };

  config = mkIf cfg.enable {
    custom.system.home = {
      configFile = {
        # ref: https://github.com/nix-community/home-manager/issues/1213
        "mimeapps.list".force = true;
      };
      extraOptions = {
        home = {
          enableNixpkgsReleaseCheck = false;

          inherit (config.system) stateVersion;
          inherit (cfg) file;
        };
        xdg = {
          enable = true;
          inherit (cfg) configFile;
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
