{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.xdg;
in
{
  options.custom.system.xdg = {
    enable = mkEnableOption "XDG base directory compliance";
    persistUserDirs = mkEnableOption "Persist user XDG directories, e.g. documents";
  };

  config = mkIf cfg.enable {
    environment.sessionVariables = {
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
    };

    environment.etc = {
      "xdg/user-dirs.defaults".text = ''
        				DESKTOP=desktop
        				DOWNLOAD=downloads
        				TEMPLATES=vorlagen
        				PUBLICSHARE=freigabe
        				DOCUMENTS=dokumente
        				MUSIC=musik
        				PICTURES=bilder
        				VIDEOS=videos
        			'';
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
      ]
      ++ (lib.optionals cfg.persistUserDirs [
        "desktop"
        "downloads"
        "vorlagen"
        "dokumente"
        "musik"
        "bilder"
        "videos"
      ]);
      files = [
        ".bash_history"
      ];
    };
  };
}
