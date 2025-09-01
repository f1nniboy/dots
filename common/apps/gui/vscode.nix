{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.vscode;
in
{
  options.custom.apps.vscode = {
    enable = mkEnableOption "Visual Studio Code editor";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vscode
      nil # language server
      nixfmt-rfc-style # formatter
    ];

    custom.system.persistence.userConfig = {
      directories = [ ".config/Code" ];
    };

    custom.system.home.extraOptions = {
      programs.vscode = {
        enable = true;
        mutableExtensionsDir = true;

        profiles.default = {
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;

          extensions = with pkgs.vscode-extensions; [
            pkief.material-icon-theme
            jnoortheen.nix-ide
          ];

          userSettings = {
            "telemetry.telemetryLevel" = "off";
            "update.showReleaseNotes" = false;
            "workbench.iconTheme" = "material-icon-theme";
            "workbench.startupEditor" = "none";
            "editor.fontFamily" = "'FiraCode Nerd Font', monospace";
            "terminal.integrated.fontFamily" = "'FiraCode Nerd Font', monospace";
            "window.zoomLevel" = 1;
            "nix.enableLanguageServer" = true;
            "files.autoSave" = "afterDelay";
            "security.workspace.trust.enabled" = false;
            "window.autoDetectColorScheme" = true;
          };
        };

      };
    };
  };
}
