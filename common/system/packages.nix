{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.system.packages;
in
{
  options.custom.system.packages = {
    enable = mkEnableOption "common system packages";
  };

  config = mkIf cfg.enable {
    environment.defaultPackages = mkForce [ ];

    environment.systemPackages = with pkgs; [
      # utilities
      efibootmgr
      bottom
      just
      statix
      fd

      # remove bottom.desktop shortcut
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
