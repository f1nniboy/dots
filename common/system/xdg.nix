{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.xdg;
in
{
  options.custom.system.xdg = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.sessionVariables = {
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
    };

    custom.system.persistence.userConfig = {
      directories = [
        ".cache"
        ".local"
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }

        "Desktop"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Videos"
        "Projects"

        "source" # temp
      ];
      files = [
        ".bash_history"
      ];
    };
  };
}
