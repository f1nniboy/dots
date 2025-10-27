{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.bottom;
in
{
  options.custom.apps.bottom = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.bottom

      # remove desktop shortcut
      (lib.hiPrio (
        pkgs.runCommand "bottom.desktop-hide" { } ''
          mkdir -p "$out/share/applications"
          cat "${pkgs.bottom}/share/applications/bottom.desktop" > "$out/share/applications/bottom.desktop"
          echo "Hidden=1" >> "$out/share/applications/bottom.desktop"
        ''
      ))
    ];
  };
}
