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
    unfreePackages = mkOption {
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) cfg.unfreePackages;

    environment = {
      defaultPackages = mkForce [ ];
      systemPackages = with pkgs; [
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
  };
}
