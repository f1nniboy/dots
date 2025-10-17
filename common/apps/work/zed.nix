{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.zed;
in
{
  options.custom.apps.zed = {
    enable = mkEnableOption "Zed editor";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # language servers
      nil
      nixd

      # formatter
      nixfmt-rfc-style
    ];

    custom.system.home.extraOptions = {
      programs.zed-editor = {
        enable = true;

        userSettings = {
          ui_font_family = "Adwaita Sans";
          ui_font_size = 16;

          buffer_font_family = "FiraCode Nerd Font Mono";
          buffer_font_size = 14;

          git = {
            inline_blame = {
              enabled = false;
            };
          };

          theme = {
            mode = "system";
            light = "Ayu Light";
            dark = "Ayu Dark";
          };

          disable_ai = true;

          title_bar = {
            show_sign_in = false;
          };

          telemetry = {
            diagnostics = false;
            metrics = false;
          };
        };
      };
    };
  };
}
