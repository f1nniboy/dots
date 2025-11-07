{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.apps.zed;
in
{
  options.custom.apps.zed = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    custom.system.home.extraOptions = {
      programs.zed-editor = {
        enable = true;

        extensions = [
          "nix"
          "git-firefly"
          "just"
        ];

        userSettings = {
          ui_font_family = "FiraCode Nerd Font Mono";
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

          languages = {
            Nix = {
              # only use nixd as lsp
              language_servers = [
                "nixd"
                "!nil"
              ];
            };
          };
        };
      };
    };
  };
}
