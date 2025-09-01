{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.helix;
in
{
  options.custom.apps.helix = {
    enable = mkEnableOption "Helix text editor";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.helix ];

    custom.system.home.extraOptions = {
      programs.helix = {
        enable = true;
        defaultEditor = true;
        settings = {
          editor = {
            line-number = "relative";
            cursorline = true;
            color-modes = true;
          };

          editor.cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          editor.indent-guides = {
            render = true;
          };
        };
      };
    };
  };
}
