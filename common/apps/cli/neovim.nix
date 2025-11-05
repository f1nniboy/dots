{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.neovim;
in
{
  options.custom.apps.neovim = {
    enable = custom.enableOption;
    defaultEditor = custom.enableOption;
  };

  config = mkIf cfg.enable {
    programs.neovim.enable = true;

    environment = {
      systemPackages = [
        # remove desktop shortcut
        (hiPrio (
          pkgs.runCommand "nvim.desktop-hide" { } ''
            mkdir -p "$out/share/applications"
            cat "${config.programs.neovim.finalPackage}/share/applications/nvim.desktop" > "$out/share/applications/nvim.desktop"
            echo "Hidden=1" >> "$out/share/applications/nvim.desktop"
          ''
        ))
      ];

      variables = mkIf cfg.defaultEditor {
        EDITOR = "nvim";
      };
    };
  };
}
